from __future__ import annotations

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import CurriculumCourse, Department, Faculty, Program, Semester, UserStatus
from app.modules.academic_structure.repository import (
    CurriculumCourseRepository,
    DepartmentRepository,
    FacultyRepository,
    ProgramRepository,
    SemesterRepository,
)
from app.modules.academic_structure.schemas import (
    DepartmentCreate,
    DepartmentUpdate,
    FacultyCreate,
    FacultyUpdate,
    ProgramCreate,
    ProgramUpdate,
    SemesterCreate,
    SemesterUpdate,
)


class FacultyService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = FacultyRepository(session)

    async def create(self, payload: FacultyCreate) -> Faculty:
        if await self.repo.get_by_code(payload.code):
            raise HTTPException(
                status.HTTP_409_CONFLICT, f"Faculty code '{payload.code}' already exists"
            )
        faculty = Faculty(
            name=payload.name,
            code=payload.code.upper(),
            description=payload.description,
            dean_id=payload.dean_id,
            status=UserStatus.ACTIVE,
        )
        return await self.repo.create(faculty)

    async def list(self) -> list[Faculty]:
        return await self.repo.list()

    async def get(self, faculty_id: UUID) -> Faculty:
        return await self.repo.get_or_404(faculty_id)

    async def update(self, faculty_id: UUID, payload: FacultyUpdate) -> Faculty:
        faculty = await self.repo.get_or_404(faculty_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(faculty, field, value)
        return await self.repo.update(faculty)


class DepartmentService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = DepartmentRepository(session)

    async def create(self, payload: DepartmentCreate) -> Department:
        if await self.repo.get_by_code(payload.code):
            raise HTTPException(
                status.HTTP_409_CONFLICT, f"Department code '{payload.code}' already exists"
            )
        dept = Department(
            name=payload.name,
            code=payload.code.upper(),
            faculty_id=payload.faculty_id,
            hod_id=payload.hod_id,
            description=payload.description,
            status=UserStatus.ACTIVE,
        )
        return await self.repo.create(dept)

    async def list(self, faculty_id: UUID | None = None) -> list[Department]:
        if faculty_id:
            return await self.repo.list_by_faculty(faculty_id)
        return await self.repo.list()

    async def get(self, dept_id: UUID) -> Department:
        return await self.repo.get_or_404(dept_id)

    async def update(self, dept_id: UUID, payload: DepartmentUpdate) -> Department:
        dept = await self.repo.get_or_404(dept_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(dept, field, value)
        return await self.repo.update(dept)


class ProgramService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = ProgramRepository(session)
        self.curriculum_repo: CurriculumCourseRepository | None = None

    def _curriculum_repo(self, session: AsyncSession) -> CurriculumCourseRepository:
        if self.curriculum_repo is None:
            self.curriculum_repo = CurriculumCourseRepository(session)
        return self.curriculum_repo

    async def create(self, payload: ProgramCreate, session: AsyncSession) -> Program:
        if await self.repo.get_by_code(payload.code):
            raise HTTPException(
                status.HTTP_409_CONFLICT, f"Program code '{payload.code}' already exists"
            )
        program = Program(
            name=payload.name,
            code=payload.code.upper(),
            department_id=payload.department_id,
            duration_years=payload.duration_years,
            total_credits=payload.total_credits,
            award_type=payload.award_type,
            description=payload.description,
            status=UserStatus.ACTIVE,
        )
        return await self.repo.create(program)

    async def list(self, department_id: UUID | None = None) -> list[Program]:
        if department_id:
            return await self.repo.list_by_department(department_id)
        return await self.repo.list()

    async def get(self, program_id: UUID) -> Program:
        return await self.repo.get_or_404(program_id)

    async def update(self, program_id: UUID, payload: ProgramUpdate) -> Program:
        program = await self.repo.get_or_404(program_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(program, field, value)
        return await self.repo.update(program)

    async def get_curriculum(
        self, program_id: UUID, session: AsyncSession
    ) -> list[CurriculumCourse]:
        await self.repo.get_or_404(program_id)
        return await self._curriculum_repo(session).list_by_program(program_id)

    async def add_to_curriculum(
        self, program_id: UUID, payload, session: AsyncSession
    ) -> CurriculumCourse:
        from app.db.sis_models import CurriculumCourse

        await self.repo.get_or_404(program_id)
        curriculum_course = CurriculumCourse(
            program_id=program_id,
            course_id=payload.course_id,
            level=payload.level,
            semester_offered=payload.semester_offered,
            is_core=payload.is_core,
            is_elective=payload.is_elective,
            min_credit_units=payload.min_credit_units,
            notes=payload.notes,
        )
        return await self._curriculum_repo(session).create(curriculum_course)

    async def remove_from_curriculum(self, cc_id: UUID, session: AsyncSession) -> None:
        repo = self._curriculum_repo(session)
        cc = await repo.get_or_404(cc_id)
        await repo.delete(cc)


class SemesterService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = SemesterRepository(session)

    async def create(self, payload: SemesterCreate) -> Semester:
        semester = Semester(
            name=payload.name,
            academic_year=payload.academic_year,
            semester_number=payload.semester_number,
            start_date=payload.start_date,
            end_date=payload.end_date,
            registration_start=payload.registration_start,
            registration_end=payload.registration_end,
            exam_start_date=payload.exam_start_date,
            exam_end_date=payload.exam_end_date,
            is_active=False,
            status="UPCOMING",
        )
        return await self.repo.create(semester)

    async def list(self, academic_year: str | None = None) -> list[Semester]:
        if academic_year:
            return await self.repo.list_by_year(academic_year)
        return await self.repo.list()

    async def get(self, semester_id: UUID) -> Semester:
        return await self.repo.get_or_404(semester_id)

    async def update(self, semester_id: UUID, payload: SemesterUpdate) -> Semester:
        semester = await self.repo.get_or_404(semester_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(semester, field, value)
        return await self.repo.update(semester)

    async def activate(self, semester_id: UUID) -> Semester:
        semester = await self.repo.get_or_404(semester_id)
        await self.repo.deactivate_all()
        semester.is_active = True
        semester.status = "ACTIVE"
        return await self.repo.update(semester)
