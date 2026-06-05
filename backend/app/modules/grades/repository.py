from __future__ import annotations

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import AcademicStanding, Enrollment, Grade, GradeAssessment


class GradeAssessmentRepository(AsyncRepository[GradeAssessment]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, GradeAssessment)

    async def list_by_course(self, course_id: UUID) -> list[GradeAssessment]:
        result = await self.session.execute(
            select(GradeAssessment).where(GradeAssessment.course_id == course_id)
        )
        return list(result.scalars().all())


class GradeRepository(AsyncRepository[Grade]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Grade)

    async def get_by_enrollment_assessment(
        self, enrollment_id: UUID, assessment_id: UUID
    ) -> Grade | None:
        result = await self.session.execute(
            select(Grade).where(
                Grade.enrollment_id == enrollment_id,
                Grade.assessment_id == assessment_id,
            )
        )
        return result.scalar_one_or_none()

    async def list_by_enrollment(self, enrollment_id: UUID) -> list[Grade]:
        result = await self.session.execute(
            select(Grade).where(Grade.enrollment_id == enrollment_id)
        )
        return list(result.scalars().all())

    async def list_for_student(self, student_id: UUID) -> list[Grade]:
        result = await self.session.execute(
            select(Grade)
            .join(Enrollment, Enrollment.enrollment_id == Grade.enrollment_id)
            .where(Enrollment.student_id == student_id)
        )
        return list(result.scalars().all())

    async def list_for_course(self, course_id: UUID) -> list[Grade]:
        result = await self.session.execute(
            select(Grade)
            .join(Enrollment, Enrollment.enrollment_id == Grade.enrollment_id)
            .where(Enrollment.course_id == course_id)
        )
        return list(result.scalars().all())


class AcademicStandingRepository(AsyncRepository[AcademicStanding]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, AcademicStanding)

    async def get_current_for_student(self, student_id: UUID) -> AcademicStanding | None:
        result = await self.session.execute(
            select(AcademicStanding).where(
                AcademicStanding.student_id == student_id,
                AcademicStanding.is_current.is_(True),
            )
        )
        return result.scalar_one_or_none()

    async def get_for_semester(
        self, student_id: UUID, semester_id: UUID
    ) -> AcademicStanding | None:
        result = await self.session.execute(
            select(AcademicStanding).where(
                AcademicStanding.student_id == student_id,
                AcademicStanding.semester_id == semester_id,
            )
        )
        return result.scalar_one_or_none()

    async def clear_current(self, student_id: UUID) -> None:
        from sqlalchemy import update

        await self.session.execute(
            update(AcademicStanding)
            .where(AcademicStanding.student_id == student_id)
            .values(is_current=False)
        )
        await self.session.commit()
