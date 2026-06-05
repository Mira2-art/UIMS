from __future__ import annotations

from datetime import time
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import Course, CourseMaterial, Prerequisite, Student, TimetableEntry
from app.modules.courses.repository import (
    CourseMaterialRepository,
    CourseRepository,
    PrerequisiteRepository,
    TimetableEntryRepository,
)
from app.modules.courses.schemas import (
    AssignLecturerRequest,
    CourseCreate,
    CourseMaterialCreate,
    CourseUpdate,
    PrerequisiteCreate,
    TimetableEntryCreate,
)


class CourseService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = CourseRepository(session)

    async def create(self, payload: CourseCreate) -> Course:
        if await self.repo.get_by_code_and_semester(payload.code, payload.semester_id):
            raise HTTPException(
                status.HTTP_409_CONFLICT,
                f"Course code '{payload.code}' already exists in this semester",
            )
        course = Course(
            code=payload.code.upper(),
            title=payload.title,
            credit_units=payload.credit_units,
            program_id=payload.program_id,
            semester_id=payload.semester_id,
            lecturer_id=payload.lecturer_id,
            max_capacity=payload.max_capacity,
            description=payload.description,
            status="ACTIVE",
        )
        return await self.repo.create(course)

    async def list(
        self,
        program_id: UUID | None = None,
        semester_id: UUID | None = None,
        lecturer_id: UUID | None = None,
        course_status: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Course]:
        return await self.repo.list_filtered(
            program_id, semester_id, lecturer_id, course_status, limit, offset
        )

    async def get(self, course_id: UUID) -> Course:
        return await self.repo.get_or_404(course_id)

    async def update(self, course_id: UUID, payload: CourseUpdate) -> Course:
        course = await self.repo.get_or_404(course_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(course, field, value)
        return await self.repo.update(course)

    async def assign_lecturer(self, course_id: UUID, payload: AssignLecturerRequest) -> Course:
        course = await self.repo.get_or_404(course_id)
        course.lecturer_id = payload.lecturer_id
        return await self.repo.update(course)

    async def get_enrolled_students(self, course_id: UUID) -> list[Student]:
        await self.repo.get_or_404(course_id)
        return await self.repo.get_enrolled_students(course_id)

    async def set_syllabus(self, course_id: UUID, syllabus_path: str) -> Course:
        course = await self.repo.get_or_404(course_id)
        course.syllabus_path = syllabus_path
        return await self.repo.update(course)


class PrerequisiteService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = PrerequisiteRepository(session)

    async def add(self, course_id: UUID, payload: PrerequisiteCreate) -> Prerequisite:
        if payload.prereq_course_id == course_id:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "A course cannot be its own prerequisite"
            )
        if await self.repo.get_by_pair(course_id, payload.prereq_course_id):
            raise HTTPException(status.HTTP_409_CONFLICT, "Prerequisite already exists")
        prereq = Prerequisite(
            course_id=course_id,
            prereq_course_id=payload.prereq_course_id,
            is_corequisite=payload.is_corequisite,
            is_strict=payload.is_strict,
            notes=payload.notes,
        )
        return await self.repo.create(prereq)

    async def list(self, course_id: UUID) -> list[Prerequisite]:
        return await self.repo.list_by_course(course_id)

    async def remove(self, prereq_id: UUID) -> None:
        prereq = await self.repo.get_or_404(prereq_id)
        await self.repo.delete(prereq)


class CourseMaterialService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = CourseMaterialRepository(session)

    async def add(
        self, course_id: UUID, payload: CourseMaterialCreate, uploaded_by: UUID
    ) -> CourseMaterial:
        material = CourseMaterial(
            course_id=course_id,
            title=payload.title,
            material_type=payload.material_type,
            description=payload.description,
            file_path=payload.file_path,
            external_url=payload.external_url,
            is_published=payload.is_published,
            uploaded_by=uploaded_by,
        )
        return await self.repo.create(material)

    async def list(self, course_id: UUID) -> list[CourseMaterial]:
        return await self.repo.list_by_course(course_id)

    async def remove(self, material_id: UUID) -> None:
        material = await self.repo.get_or_404(material_id)
        await self.repo.delete(material)


class TimetableService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = TimetableEntryRepository(session)

    async def add(self, course_id: UUID, payload: TimetableEntryCreate) -> TimetableEntry:
        entry = TimetableEntry(
            course_id=course_id,
            day_of_week=payload.day_of_week.upper(),
            start_time=time.fromisoformat(payload.start_time),
            end_time=time.fromisoformat(payload.end_time),
            venue=payload.venue,
            entry_type=payload.entry_type,
            recurrence=payload.recurrence,
        )
        return await self.repo.create(entry)

    async def list(self, course_id: UUID) -> list[TimetableEntry]:
        return await self.repo.list_by_course(course_id)
