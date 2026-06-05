from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import CurriculumCourse, Department, Faculty, Program, Semester


class FacultyRepository(AsyncRepository[Faculty]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Faculty)

    async def get_by_code(self, code: str) -> Faculty | None:
        result = await self.session.execute(select(Faculty).where(Faculty.code == code))
        return result.scalar_one_or_none()

    async def list_active(self) -> list[Faculty]:
        result = await self.session.execute(select(Faculty).where(Faculty.status == "ACTIVE"))
        return list(result.scalars().all())


class DepartmentRepository(AsyncRepository[Department]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Department)

    async def get_by_code(self, code: str) -> Department | None:
        result = await self.session.execute(select(Department).where(Department.code == code))
        return result.scalar_one_or_none()

    async def list_by_faculty(self, faculty_id: UUID) -> list[Department]:
        result = await self.session.execute(
            select(Department).where(Department.faculty_id == faculty_id)
        )
        return list(result.scalars().all())


class ProgramRepository(AsyncRepository[Program]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Program)

    async def get_by_code(self, code: str) -> Program | None:
        result = await self.session.execute(select(Program).where(Program.code == code))
        return result.scalar_one_or_none()

    async def list_by_department(self, department_id: UUID) -> list[Program]:
        result = await self.session.execute(
            select(Program).where(Program.department_id == department_id)
        )
        return list(result.scalars().all())


class SemesterRepository(AsyncRepository[Semester]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Semester)

    async def get_active(self) -> Semester | None:
        result = await self.session.execute(select(Semester).where(Semester.is_active.is_(True)))
        return result.scalar_one_or_none()

    async def list_by_year(self, academic_year: str) -> list[Semester]:
        result = await self.session.execute(
            select(Semester).where(Semester.academic_year == academic_year)
        )
        return list(result.scalars().all())

    async def deactivate_all(self) -> None:
        await self.session.execute(update(Semester).values(is_active=False))
        await self.session.commit()


class CurriculumCourseRepository(AsyncRepository[CurriculumCourse]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, CurriculumCourse)

    async def list_by_program(self, program_id: UUID) -> list[CurriculumCourse]:
        result = await self.session.execute(
            select(CurriculumCourse).where(CurriculumCourse.program_id == program_id)
        )
        return list(result.scalars().all())
