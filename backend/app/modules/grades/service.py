from __future__ import annotations

from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import (
    AcademicStanding,
    AcademicStandingType,
    Enrollment,
    Grade,
    GradeAssessment,
)
from app.modules.grades.repository import (
    AcademicStandingRepository,
    GradeAssessmentRepository,
    GradeRepository,
)
from app.modules.grades.schemas import (
    AcademicStandingCreate,
    AssessmentCreate,
    AssessmentUpdate,
    GradeSubmit,
)


def _compute_letter_grade(percentage: Decimal) -> str:
    if percentage >= 70:
        return "A"
    if percentage >= 60:
        return "B"
    if percentage >= 50:
        return "C"
    if percentage >= 45:
        return "D"
    return "F"


def _grade_points(letter: str) -> Decimal:
    return {
        "A": Decimal("5.0"),
        "B": Decimal("4.0"),
        "C": Decimal("3.0"),
        "D": Decimal("2.0"),
        "F": Decimal("0.0"),
    }.get(letter, Decimal("0.0"))


class AssessmentService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = GradeAssessmentRepository(session)

    async def create(self, payload: AssessmentCreate, created_by: UUID) -> GradeAssessment:
        assessment = GradeAssessment(
            course_id=payload.course_id,
            assessment_type=payload.assessment_type,
            name=payload.name,
            description=payload.description,
            max_score=payload.max_score,
            weight_percent=payload.weight_percent,
            due_date=payload.due_date,
            is_published=False,
            created_by=created_by,
        )
        return await self.repo.create(assessment)

    async def list(self, course_id: UUID) -> list[GradeAssessment]:
        return await self.repo.list_by_course(course_id)

    async def get(self, assessment_id: UUID) -> GradeAssessment:
        return await self.repo.get_or_404(assessment_id)

    async def update(self, assessment_id: UUID, payload: AssessmentUpdate) -> GradeAssessment:
        assessment = await self.repo.get_or_404(assessment_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(assessment, field, value)
        return await self.repo.update(assessment)


class GradeService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = GradeRepository(session)
        self.assessment_repo = GradeAssessmentRepository(session)

    async def submit(self, payload: GradeSubmit) -> Grade:
        existing = await self.repo.get_by_enrollment_assessment(
            payload.enrollment_id, payload.assessment_id
        )
        if existing:
            raise HTTPException(
                status.HTTP_409_CONFLICT,
                "Grade already submitted for this enrollment and assessment",
            )

        assessment = await self.assessment_repo.get_or_404(payload.assessment_id)
        if payload.score > assessment.max_score:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Score {payload.score} exceeds max score {assessment.max_score}",
            )

        percentage = (payload.score / assessment.max_score) * Decimal("100")
        letter = _compute_letter_grade(percentage)

        grade = Grade(
            enrollment_id=payload.enrollment_id,
            assessment_id=payload.assessment_id,
            score=payload.score,
            percentage=percentage.quantize(Decimal("0.01")),
            letter_grade=letter,
            remarks=payload.remarks,
            is_published=False,
        )
        return await self.repo.create(grade)

    async def list(
        self,
        course_id: UUID | None = None,
        student_id: UUID | None = None,
    ) -> list[Grade]:
        if student_id:
            return await self.repo.list_for_student(student_id)
        if course_id:
            return await self.repo.list_for_course(course_id)
        return await self.repo.list()

    async def publish(self, grade_id: UUID, published_by: UUID) -> Grade:
        grade = await self.repo.get_or_404(grade_id)
        grade.is_published = True
        grade.published_at = datetime.now(UTC)
        grade.published_by = published_by
        return await self.repo.update(grade)

    async def get_transcript(self, student_id: UUID) -> list[Grade]:
        grades = await self.repo.list_for_student(student_id)
        return [g for g in grades if g.is_published]


class StandingService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = AcademicStandingRepository(session)
        self.grade_repo = GradeRepository(session)

    async def compute_and_record(self, payload: AcademicStandingCreate) -> AcademicStanding:
        from sqlalchemy import select

        from app.db.sis_models import Course

        enrollments = await self.repo.session.execute(
            select(Enrollment).where(
                Enrollment.student_id == payload.student_id,
                Enrollment.status == "ACTIVE",
            )
        )
        enrollments = list(enrollments.scalars().all())

        total_weighted_points = Decimal("0")
        total_credits_attempted = 0
        total_credits_earned = 0

        for enrollment in enrollments:
            course = await self.repo.session.get(Course, enrollment.course_id)
            if not course:
                continue
            grades = await self.grade_repo.list_by_enrollment(enrollment.enrollment_id)
            if not grades:
                continue

            best_letter = max((g.letter_grade or "F") for g in grades) if grades else "F"
            gp = _grade_points(best_letter)
            total_weighted_points += gp * course.credit_units
            total_credits_attempted += course.credit_units
            if best_letter != "F":
                total_credits_earned += course.credit_units

        gpa = (
            (total_weighted_points / total_credits_attempted).quantize(Decimal("0.01"))
            if total_credits_attempted
            else Decimal("0.00")
        )

        if gpa >= Decimal("4.5"):
            standing_type = AcademicStandingType.DEANS_LIST
        elif gpa >= Decimal("1.5"):
            standing_type = AcademicStandingType.GOOD_STANDING
        else:
            standing_type = AcademicStandingType.PROBATION

        await self.repo.clear_current(payload.student_id)
        prev = await self.repo.get_for_semester(payload.student_id, payload.semester_id)
        if prev:
            prev.gpa = gpa
            prev.total_credits_attempted = total_credits_attempted
            prev.total_credits_earned = total_credits_earned
            prev.standing = standing_type
            prev.is_current = True
            return await self.repo.update(prev)

        record = AcademicStanding(
            student_id=payload.student_id,
            semester_id=payload.semester_id,
            gpa=gpa,
            cgpa=gpa,
            total_credits_attempted=total_credits_attempted,
            total_credits_earned=total_credits_earned,
            standing=standing_type,
            is_current=True,
        )
        return await self.repo.create(record)

    async def get_current(self, student_id: UUID) -> AcademicStanding | None:
        return await self.repo.get_current_for_student(student_id)
