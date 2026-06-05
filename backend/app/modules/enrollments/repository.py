from __future__ import annotations

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import Enrollment


class EnrollmentRepository(AsyncRepository[Enrollment]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Enrollment)

    async def get_by_student_course(self, student_id: UUID, course_id: UUID) -> Enrollment | None:
        result = await self.session.execute(
            select(Enrollment).where(
                Enrollment.student_id == student_id,
                Enrollment.course_id == course_id,
            )
        )
        return result.scalar_one_or_none()

    async def list_filtered(
        self,
        student_id: UUID | None = None,
        course_id: UUID | None = None,
        enroll_status: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Enrollment]:
        query = select(Enrollment)
        if student_id:
            query = query.where(Enrollment.student_id == student_id)
        if course_id:
            query = query.where(Enrollment.course_id == course_id)
        if enroll_status:
            query = query.where(Enrollment.status == enroll_status)
        result = await self.session.execute(query.offset(offset).limit(limit))
        return list(result.scalars().all())
