from __future__ import annotations

from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import _get_user_role_codes
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

# ── Grading architecture ─────────────────────────────────────────────────────
# A course is graded in two components that sum to a mark out of 100:
#   • CA   — Continuous Assessment, max 30, entered by the LECTURER
#            (assessment_type CA_TEST / CA_ASSIGNMENT / CA_QUIZ / CA_PROJECT).
#   • EXAM — written exam, max 70, entered by the Faculty Dean / School
#            Secretariat / Admin (assessment_type EXAM / FINAL).
# The final letter grade is computed from the COMBINED total (CA + EXAM), never
# from a single assessment. CA weights must sum to <= 30 and EXAM to <= 70.

CA_MAX_WEIGHT = Decimal("30")
EXAM_MAX_WEIGHT = Decimal("70")

# Who may enter each component (role_codes). Exam entry is further restricted to
# staff affiliated with the course's faculty (see _user_faculty_ids), except the
# global roles below. Supported dual roles: dean/lecturer, registrar/lecturer,
# admin/lecturer — all carry a Lecturer record that anchors faculty affiliation.
CA_ENTRY_ROLES = {"LECTURER", "ADMIN", "SUPER_ADMIN"}
EXAM_ENTRY_ROLES = {"DEAN", "REGISTRAR", "ADMIN", "SUPER_ADMIN"}
GLOBAL_ROLES = {"ADMIN", "SUPER_ADMIN"}  # bypass faculty-affiliation scoping


def _is_ca(assessment_type: str) -> bool:
    """CA_* types are continuous assessment; EXAM/FINAL are the written exam."""
    return assessment_type.upper().startswith("CA")


def _compute_letter_grade(total: Decimal) -> str:
    """Map a combined mark out of 100 (CA/30 + EXAM/70) to a letter grade."""
    if total >= Decimal("96"):
        return "A+"
    if total >= Decimal("80"):
        return "A"
    if total >= Decimal("70"):
        return "B+"
    if total >= Decimal("60"):
        return "B"
    if total >= Decimal("55"):
        return "C+"
    if total >= Decimal("50"):
        return "C"
    if total >= Decimal("45"):
        return "D+"
    if total >= Decimal("40"):
        return "D"
    return "F"


# Grade points on a 4.0 scale (Cameroon university convention).
_GRADE_POINTS = {
    "A+": Decimal("4.0"),
    "A": Decimal("4.0"),
    "B+": Decimal("3.5"),
    "B": Decimal("3.0"),
    "C+": Decimal("2.5"),
    "C": Decimal("2.0"),
    "D+": Decimal("1.5"),
    "D": Decimal("1.0"),
    "F": Decimal("0.0"),
}


def _grade_points(letter: str) -> Decimal:
    return _GRADE_POINTS.get(letter, Decimal("0.0"))


def compute_course_grade(
    items: list[tuple[Decimal, Decimal, Decimal]],
) -> tuple[Decimal, str]:
    """Weighted total + letter from (score, max_score, weight_percent) rows.

    Each item contributes (score / max_score) * weight_percent. With CA weights
    summing to 30 and EXAM to 70, the total is the mark out of 100.
    """
    total = Decimal("0")
    for score, max_score, weight in items:
        if max_score and max_score > 0:
            total += (score / max_score) * weight
    total = total.quantize(Decimal("0.01"))
    return total, _compute_letter_grade(total)


async def _course_faculty_id(session: AsyncSession, course_id: UUID) -> UUID | None:
    """A course's faculty: Course → Program → Department → Faculty."""
    from app.db.sis_models import Course, Department, Program

    course = await session.get(Course, course_id)
    if course is None:
        return None
    program = await session.get(Program, course.program_id)
    if program is None:
        return None
    department = await session.get(Department, program.department_id)
    return department.faculty_id if department else None


async def _user_faculty_ids(session: AsyncSession, user_id: UUID) -> set[UUID]:
    """Faculties a user belongs to: via their Lecturer department + any deanship."""
    from sqlalchemy import select

    from app.db.sis_models import Department, Faculty, Lecturer

    faculties: set[UUID] = set()
    lecturers = (
        await session.execute(select(Lecturer).where(Lecturer.user_id == user_id))
    ).scalars().all()
    for lecturer in lecturers:
        department = await session.get(Department, lecturer.department_id)
        if department:
            faculties.add(department.faculty_id)
        led = (
            await session.execute(
                select(Faculty).where(Faculty.dean_id == lecturer.lecturer_id)
            )
        ).scalars().all()
        faculties.update(f.faculty_id for f in led)
    return faculties


class AssessmentService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = GradeAssessmentRepository(session)

    async def _assert_weight_within_bucket(
        self,
        course_id: UUID,
        assessment_type: str,
        weight: Decimal,
        exclude_id: UUID | None = None,
    ) -> None:
        is_ca = _is_ca(assessment_type)
        cap = CA_MAX_WEIGHT if is_ca else EXAM_MAX_WEIGHT
        existing = await self.repo.list_by_course(course_id)
        used = sum(
            (
                a.weight_percent
                for a in existing
                if _is_ca(a.assessment_type) == is_ca and a.assessment_id != exclude_id
            ),
            Decimal("0"),
        )
        if used + weight > cap:
            bucket = "CA" if is_ca else "Exam"
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"{bucket} weight would exceed {cap}% (already allocated {used}%).",
            )

    async def create(self, payload: AssessmentCreate, created_by: UUID) -> GradeAssessment:
        await self._assert_weight_within_bucket(
            payload.course_id, payload.assessment_type, payload.weight_percent
        )
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
        if payload.weight_percent is not None:
            await self._assert_weight_within_bucket(
                assessment.course_id,
                assessment.assessment_type,
                payload.weight_percent,
                exclude_id=assessment.assessment_id,
            )
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(assessment, field, value)
        return await self.repo.update(assessment)


class GradeService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repo = GradeRepository(session)
        self.assessment_repo = GradeAssessmentRepository(session)

    async def submit(self, payload: GradeSubmit, submitted_by: UUID) -> Grade:
        assessment = await self.assessment_repo.get_or_404(payload.assessment_id)

        # Role split: CA entered by lecturers, EXAM by Dean/Secretariat/Admin.
        roles = await _get_user_role_codes(submitted_by, self.session)
        is_ca = _is_ca(assessment.assessment_type)
        allowed = CA_ENTRY_ROLES if is_ca else EXAM_ENTRY_ROLES
        if not roles.intersection(allowed):
            component = "CA" if is_ca else "Exam"
            raise HTTPException(
                status.HTTP_403_FORBIDDEN,
                f"{component} scores can only be entered by: {', '.join(sorted(allowed))}.",
            )

        # Exam entry is faculty-scoped: the entrant must be affiliated with the
        # course's faculty (global admins bypass).
        if not is_ca and not roles.intersection(GLOBAL_ROLES):
            course_faculty = await _course_faculty_id(self.session, assessment.course_id)
            user_faculties = await _user_faculty_ids(self.session, submitted_by)
            if course_faculty is None or course_faculty not in user_faculties:
                raise HTTPException(
                    status.HTTP_403_FORBIDDEN,
                    "Exam marks can only be entered by staff affiliated with the "
                    "course's faculty.",
                )

        existing = await self.repo.get_by_enrollment_assessment(
            payload.enrollment_id, payload.assessment_id
        )
        if existing:
            raise HTTPException(
                status.HTTP_409_CONFLICT,
                "Grade already submitted for this enrollment and assessment",
            )

        if payload.score > assessment.max_score:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Score {payload.score} exceeds max score {assessment.max_score}",
            )

        # Per-assessment percentage is informational. The final letter grade is
        # derived from the combined CA+EXAM total (see compute_course_grade), so
        # we do NOT stamp a letter on a single assessment row.
        percentage = (payload.score / assessment.max_score) * Decimal("100")

        grade = Grade(
            enrollment_id=payload.enrollment_id,
            assessment_id=payload.assessment_id,
            score=payload.score,
            percentage=percentage.quantize(Decimal("0.01")),
            letter_grade=None,
            remarks=payload.remarks,
            is_published=False,
        )
        return await self.repo.create(grade)

    async def bulk_submit(self, items: list, submitted_by: UUID) -> list[Grade]:
        """Submit/correct many grades at once (Excel upload, score grids).

        Same role + faculty + cap checks as single submit, per row; upserts so a
        re-upload corrects existing scores instead of failing on conflict. Fails
        fast with the offending row index on a validation error.
        """
        roles = await _get_user_role_codes(submitted_by, self.session)
        faculties: set | None = None
        out: list[Grade] = []
        for index, item in enumerate(items):
            assessment = await self.assessment_repo.get_or_404(item.assessment_id)
            is_ca = _is_ca(assessment.assessment_type)
            allowed = CA_ENTRY_ROLES if is_ca else EXAM_ENTRY_ROLES
            if not roles.intersection(allowed):
                component = "CA" if is_ca else "Exam"
                raise HTTPException(
                    status.HTTP_403_FORBIDDEN,
                    f"Row {index}: {component} scores can only be entered by: "
                    f"{', '.join(sorted(allowed))}.",
                )
            if not is_ca and not roles.intersection(GLOBAL_ROLES):
                if faculties is None:
                    faculties = await _user_faculty_ids(self.session, submitted_by)
                course_faculty = await _course_faculty_id(self.session, assessment.course_id)
                if course_faculty is None or course_faculty not in faculties:
                    raise HTTPException(
                        status.HTTP_403_FORBIDDEN,
                        f"Row {index}: exam marks are restricted to the course's faculty.",
                    )
            if item.score > assessment.max_score:
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST,
                    f"Row {index}: score {item.score} exceeds max {assessment.max_score}.",
                )

            percentage = (item.score / assessment.max_score) * Decimal("100")
            existing = await self.repo.get_by_enrollment_assessment(
                item.enrollment_id, item.assessment_id
            )
            if existing:
                existing.score = item.score
                existing.percentage = percentage.quantize(Decimal("0.01"))
                existing.letter_grade = None
                existing.remarks = item.remarks
                out.append(await self.repo.update(existing))
            else:
                out.append(
                    await self.repo.create(
                        Grade(
                            enrollment_id=item.enrollment_id,
                            assessment_id=item.assessment_id,
                            score=item.score,
                            percentage=percentage.quantize(Decimal("0.01")),
                            letter_grade=None,
                            remarks=item.remarks,
                            is_published=False,
                        )
                    )
                )
        return out

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

    async def course_result(self, enrollment_id: UUID) -> dict:
        """Combined CA + EXAM result for one enrollment (the final course grade)."""
        grades = await self.repo.list_by_enrollment(enrollment_id)
        ca_total = Decimal("0")
        exam_total = Decimal("0")
        items: list[tuple[Decimal, Decimal, Decimal]] = []
        for g in grades:
            assessment = await self.assessment_repo.get_or_404(g.assessment_id)
            items.append((g.score, assessment.max_score, assessment.weight_percent))
            if assessment.max_score and assessment.max_score > 0:
                contribution = (g.score / assessment.max_score) * assessment.weight_percent
                if _is_ca(assessment.assessment_type):
                    ca_total += contribution
                else:
                    exam_total += contribution
        total, letter = compute_course_grade(items)
        return {
            "enrollment_id": enrollment_id,
            "ca_score": ca_total.quantize(Decimal("0.01")),
            "exam_score": exam_total.quantize(Decimal("0.01")),
            "total_score": total,
            "letter_grade": letter,
            "grade_point": _grade_points(letter),
        }

    async def student_transcript(self, student_id: UUID) -> dict:
        """Student-facing transcript: PUBLISHED components only, for the courses
        the student is enrolled in, grouped by semester with GPA + cumulative CGPA.

        CA and EXAM are shown independently as each is published; the total/letter
        and semester GPA appear only once a course/semester is finalized.
        """
        from sqlalchemy import select

        from app.db.sis_models import Course, Enrollment, Semester

        q2 = Decimal("0.01")
        enrollments = (
            await self.session.execute(
                select(Enrollment).where(
                    Enrollment.student_id == student_id,
                    Enrollment.status.in_(["ACTIVE", "COMPLETED"]),
                )
            )
        ).scalars().all()

        by_semester: dict = {}
        for enrollment in enrollments:
            course = await self.session.get(Course, enrollment.course_id)
            if course is None:
                continue
            grades = await self.repo.list_by_enrollment(enrollment.enrollment_id)

            ca = Decimal("0")
            exam = Decimal("0")
            ca_published = False
            exam_published = False
            for g in grades:
                if not g.is_published:  # students only ever see published grades
                    continue
                assessment = await self.assessment_repo.get_or_404(g.assessment_id)
                if not assessment.max_score:
                    continue
                contribution = (g.score / assessment.max_score) * assessment.weight_percent
                if _is_ca(assessment.assessment_type):
                    ca += contribution
                    ca_published = True
                else:
                    exam += contribution
                    exam_published = True

            finalized = ca_published and exam_published
            total = (ca + exam) if finalized else None
            letter = _compute_letter_grade(total) if total is not None else None

            view = {
                "course_id": course.course_id,
                "code": course.code,
                "title": course.title,
                "credit_units": course.credit_units,
                "ca_score": ca.quantize(q2) if ca_published else None,
                "exam_score": exam.quantize(q2) if exam_published else None,
                "total": total.quantize(q2) if total is not None else None,
                "letter_grade": letter,
                "finalized": finalized,
            }
            by_semester.setdefault(course.semester_id, []).append(
                (view, finalized, letter, course.credit_units)
            )

        semesters: list[dict] = []
        cum_points = Decimal("0")
        cum_credits = 0
        for semester_id, rows in by_semester.items():
            semester = await self.session.get(Semester, semester_id)
            all_finalized = bool(rows) and all(r[1] for r in rows)
            points = Decimal("0")
            credits = 0
            for _view, fin, letter, course_credits in rows:
                if fin:
                    gp = _grade_points(letter)
                    points += gp * course_credits
                    credits += course_credits
                    cum_points += gp * course_credits
                    cum_credits += course_credits
            gpa = (points / credits).quantize(q2) if (all_finalized and credits) else None
            semesters.append(
                {
                    "semester_id": semester_id,
                    "name": semester.name if semester else "",
                    "semester_number": semester.semester_number if semester else 0,
                    "academic_year": semester.academic_year if semester else "",
                    "gpa": gpa,
                    "courses": [r[0] for r in rows],
                }
            )

        semesters.sort(
            key=lambda s: (s["academic_year"], s["semester_number"]), reverse=True
        )
        cgpa = (cum_points / cum_credits).quantize(q2) if cum_credits else None
        return {"cgpa": cgpa, "semesters": semesters}

    async def publish(self, grade_id: UUID, published_by: UUID) -> Grade:
        grade = await self.repo.get_or_404(grade_id)
        assessment = await self.assessment_repo.get_or_404(grade.assessment_id)

        # Same role split as entry: CA published by lecturers, EXAM by Dean /
        # Secretariat / Admin (faculty-scoped, global admins bypass).
        roles = await _get_user_role_codes(published_by, self.session)
        is_ca = _is_ca(assessment.assessment_type)
        allowed = CA_ENTRY_ROLES if is_ca else EXAM_ENTRY_ROLES
        if not roles.intersection(allowed):
            component = "CA" if is_ca else "Exam"
            raise HTTPException(
                status.HTTP_403_FORBIDDEN,
                f"{component} grades can only be published by: {', '.join(sorted(allowed))}.",
            )
        if not is_ca and not roles.intersection(GLOBAL_ROLES):
            course_faculty = await _course_faculty_id(self.session, assessment.course_id)
            user_faculties = await _user_faculty_ids(self.session, published_by)
            if course_faculty is None or course_faculty not in user_faculties:
                raise HTTPException(
                    status.HTTP_403_FORBIDDEN,
                    "Exam grades can only be published by staff affiliated with the course's faculty.",
                )

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
        self.assessment_repo = GradeAssessmentRepository(session)

    async def compute_and_record(self, payload: AcademicStandingCreate) -> AcademicStanding:
        """Auto-compute the student's GPA (this semester) + CGPA (cumulative).

        The system derives everything from recorded course results — nobody enters
        a GPA. For each enrolled course we compute the final mark (CA + EXAM →
        letter → 4.0 grade point) and credit-weight it:
          * **GPA**  = Σ(gp × credits) / Σ(credits) over THIS semester's courses.
          * **CGPA** = the same, cumulative over every graded semester so far
            (so it becomes meaningful from the 2nd semester onward).
        Only finalized courses count (an EXAM grade must be recorded).
        """
        from sqlalchemy import select

        from app.db.sis_models import Course

        enrollments = await self.repo.session.execute(
            select(Enrollment).where(
                Enrollment.student_id == payload.student_id,
                Enrollment.status.in_(["ACTIVE", "COMPLETED"]),
            )
        )
        enrollments = list(enrollments.scalars().all())

        sem_points = Decimal("0")  # this semester
        sem_credits = 0
        sem_earned = 0
        cum_points = Decimal("0")  # cumulative (all graded semesters)
        cum_credits = 0
        cum_earned = 0

        for enrollment in enrollments:
            course = await self.repo.session.get(Course, enrollment.course_id)
            if not course:
                continue
            grades = await self.grade_repo.list_by_enrollment(enrollment.enrollment_id)
            if not grades:
                continue

            # Final course grade = combined CA + EXAM weighted total → letter.
            items: list[tuple[Decimal, Decimal, Decimal]] = []
            has_exam = False
            for g in grades:
                assessment = await self.assessment_repo.get_or_404(g.assessment_id)
                items.append((g.score, assessment.max_score, assessment.weight_percent))
                if not _is_ca(assessment.assessment_type):
                    has_exam = True
            # A course only counts once finalized (exam recorded).
            if not has_exam:
                continue

            _total, letter = compute_course_grade(items)
            gp = _grade_points(letter)
            credits = course.credit_units
            weighted = gp * credits

            cum_points += weighted
            cum_credits += credits
            if letter != "F":
                cum_earned += credits

            if course.semester_id == payload.semester_id:
                sem_points += weighted
                sem_credits += credits
                if letter != "F":
                    sem_earned += credits

        gpa = (
            (sem_points / sem_credits).quantize(Decimal("0.01"))
            if sem_credits
            else Decimal("0.00")
        )
        cgpa = (
            (cum_points / cum_credits).quantize(Decimal("0.01"))
            if cum_credits
            else gpa
        )

        # Academic standing is judged on the CGPA (4.0 scale).
        if cgpa >= Decimal("3.5"):
            standing_type = AcademicStandingType.DEANS_LIST
        elif cgpa >= Decimal("2.0"):
            standing_type = AcademicStandingType.GOOD_STANDING
        else:
            standing_type = AcademicStandingType.PROBATION

        await self.repo.clear_current(payload.student_id)
        prev = await self.repo.get_for_semester(payload.student_id, payload.semester_id)
        if prev:
            prev.gpa = gpa
            prev.cgpa = cgpa
            prev.total_credits_attempted = cum_credits
            prev.total_credits_earned = cum_earned
            prev.standing = standing_type
            prev.is_current = True
            return await self.repo.update(prev)

        record = AcademicStanding(
            student_id=payload.student_id,
            semester_id=payload.semester_id,
            gpa=gpa,
            cgpa=cgpa,
            total_credits_attempted=cum_credits,
            total_credits_earned=cum_earned,
            standing=standing_type,
            is_current=True,
        )
        return await self.repo.create(record)

    async def get_current(self, student_id: UUID) -> AcademicStanding | None:
        return await self.repo.get_current_for_student(student_id)
