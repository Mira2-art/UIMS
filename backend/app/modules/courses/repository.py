from __future__ import annotations

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import (
    Course,
    CourseMaterial,
    Enrollment,
    Prerequisite,
    Student,
    TimetableEntry,
)


class CourseRepository(AsyncRepository[Course]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Course)

    async def get_by_code_and_semester(self, code: str, semester_id: UUID) -> Course | None:
        result = await self.session.execute(
            select(Course).where(Course.code == code, Course.semester_id == semester_id)
        )
        return result.scalar_one_or_none()

    async def list_filtered(
        self,
        program_id: UUID | None = None,
        semester_id: UUID | None = None,
        lecturer_id: UUID | None = None,
        status: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Course]:
        query = select(Course)
        if program_id:
            query = query.where(Course.program_id == program_id)
        if semester_id:
            query = query.where(Course.semester_id == semester_id)
        if lecturer_id:
            query = query.where(Course.lecturer_id == lecturer_id)
        if status:
            query = query.where(Course.status == status)
        result = await self.session.execute(query.offset(offset).limit(limit))
        return list(result.scalars().all())

    async def get_enrolled_students(self, course_id: UUID) -> list[Student]:
        result = await self.session.execute(
            select(Student)
            .join(Enrollment, Enrollment.student_id == Student.student_id)
            .where(Enrollment.course_id == course_id, Enrollment.status == "ACTIVE")
        )
        return list(result.scalars().all())


class PrerequisiteRepository(AsyncRepository[Prerequisite]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Prerequisite)

    async def list_by_course(self, course_id: UUID) -> list[Prerequisite]:
        result = await self.session.execute(
            select(Prerequisite).where(Prerequisite.course_id == course_id)
        )
        return list(result.scalars().all())

    async def get_by_pair(self, course_id: UUID, prereq_course_id: UUID) -> Prerequisite | None:
        result = await self.session.execute(
            select(Prerequisite).where(
                Prerequisite.course_id == course_id,
                Prerequisite.prereq_course_id == prereq_course_id,
            )
        )
        return result.scalar_one_or_none()


class CourseMaterialRepository(AsyncRepository[CourseMaterial]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, CourseMaterial)

    async def list_by_course(
        self, course_id: UUID, published_only: bool = False
    ) -> list[CourseMaterial]:
        query = select(CourseMaterial).where(CourseMaterial.course_id == course_id)
        if published_only:
            query = query.where(CourseMaterial.is_published.is_(True))
        result = await self.session.execute(query)
        return list(result.scalars().all())


class TimetableEntryRepository(AsyncRepository[TimetableEntry]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, TimetableEntry)

    async def list_by_course(self, course_id: UUID) -> list[TimetableEntry]:
        result = await self.session.execute(
            select(TimetableEntry).where(TimetableEntry.course_id == course_id)
        )
        return list(result.scalars().all())
