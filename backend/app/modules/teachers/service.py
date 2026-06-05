from __future__ import annotations

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import Course, Lecturer
from app.modules.teachers.repository import LecturerRepository
from app.modules.teachers.schemas import LecturerCreate, LecturerUpdate


class LecturerService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = LecturerRepository(session)

    async def create(self, payload: LecturerCreate) -> Lecturer:
        if await self.repo.get_by_staff_id(payload.staff_id):
            raise HTTPException(
                status.HTTP_409_CONFLICT, f"Staff ID '{payload.staff_id}' already exists"
            )
        if await self.repo.get_by_user_id(payload.user_id):
            raise HTTPException(
                status.HTTP_409_CONFLICT, "User is already registered as a lecturer"
            )
        lecturer = Lecturer(
            user_id=payload.user_id,
            staff_id=payload.staff_id,
            department_id=payload.department_id,
            title=payload.title,
            employment_status=payload.employment_status,
            specialization=payload.specialization,
        )
        return await self.repo.create(lecturer)

    async def list(self, department_id: UUID | None = None) -> list[Lecturer]:
        if department_id:
            return await self.repo.list_by_department(department_id)
        return await self.repo.list()

    async def get(self, lecturer_id: UUID) -> Lecturer:
        return await self.repo.get_or_404(lecturer_id)

    async def update(self, lecturer_id: UUID, payload: LecturerUpdate) -> Lecturer:
        lecturer = await self.repo.get_or_404(lecturer_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(lecturer, field, value)
        return await self.repo.update(lecturer)

    async def get_courses(self, lecturer_id: UUID) -> list[Course]:
        await self.repo.get_or_404(lecturer_id)
        return await self.repo.get_courses(lecturer_id)
