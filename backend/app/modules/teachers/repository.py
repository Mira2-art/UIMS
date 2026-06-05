from __future__ import annotations

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import Course, Lecturer


class LecturerRepository(AsyncRepository[Lecturer]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Lecturer)

    async def get_by_staff_id(self, staff_id: str) -> Lecturer | None:
        result = await self.session.execute(select(Lecturer).where(Lecturer.staff_id == staff_id))
        return result.scalar_one_or_none()

    async def get_by_user_id(self, user_id: UUID) -> Lecturer | None:
        result = await self.session.execute(select(Lecturer).where(Lecturer.user_id == user_id))
        return result.scalar_one_or_none()

    async def list_by_department(self, department_id: UUID) -> list[Lecturer]:
        result = await self.session.execute(
            select(Lecturer).where(Lecturer.department_id == department_id)
        )
        return list(result.scalars().all())

    async def get_courses(self, lecturer_id: UUID) -> list[Course]:
        result = await self.session.execute(select(Course).where(Course.lecturer_id == lecturer_id))
        return list(result.scalars().all())
