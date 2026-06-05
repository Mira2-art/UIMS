from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.academic_structure.schemas import (
    CurriculumCourseCreate,
    CurriculumCourseRead,
    DepartmentCreate,
    DepartmentRead,
    DepartmentUpdate,
    FacultyCreate,
    FacultyRead,
    FacultyUpdate,
    ProgramCreate,
    ProgramRead,
    ProgramUpdate,
    SemesterCreate,
    SemesterRead,
    SemesterUpdate,
)
from app.modules.academic_structure.service import (
    DepartmentService,
    FacultyService,
    ProgramService,
    SemesterService,
)

router = APIRouter()

# ── Faculties ──────────────────────────────────────────────────────────────────


@router.post("/faculties", response_model=FacultyRead, status_code=201)
async def create_faculty(
    payload: FacultyCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> FacultyRead:
    faculty = await FacultyService(session).create(payload)
    return FacultyRead.model_validate(faculty)


@router.get("/faculties", response_model=list[FacultyRead])
async def list_faculties(
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[FacultyRead]:
    faculties = await FacultyService(session).list()
    return [FacultyRead.model_validate(f) for f in faculties]


@router.get("/faculties/{faculty_id}", response_model=FacultyRead)
async def get_faculty(
    faculty_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> FacultyRead:
    faculty = await FacultyService(session).get(faculty_id)
    return FacultyRead.model_validate(faculty)


@router.put("/faculties/{faculty_id}", response_model=FacultyRead)
async def update_faculty(
    faculty_id: UUID,
    payload: FacultyUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> FacultyRead:
    faculty = await FacultyService(session).update(faculty_id, payload)
    return FacultyRead.model_validate(faculty)


# ── Departments ────────────────────────────────────────────────────────────────


@router.post("/departments", response_model=DepartmentRead, status_code=201)
async def create_department(
    payload: DepartmentCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> DepartmentRead:
    dept = await DepartmentService(session).create(payload)
    return DepartmentRead.model_validate(dept)


@router.get("/departments", response_model=list[DepartmentRead])
async def list_departments(
    faculty_id: UUID | None = Query(None),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[DepartmentRead]:
    depts = await DepartmentService(session).list(faculty_id)
    return [DepartmentRead.model_validate(d) for d in depts]


@router.get("/departments/{dept_id}", response_model=DepartmentRead)
async def get_department(
    dept_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> DepartmentRead:
    dept = await DepartmentService(session).get(dept_id)
    return DepartmentRead.model_validate(dept)


@router.put("/departments/{dept_id}", response_model=DepartmentRead)
async def update_department(
    dept_id: UUID,
    payload: DepartmentUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> DepartmentRead:
    dept = await DepartmentService(session).update(dept_id, payload)
    return DepartmentRead.model_validate(dept)


# ── Programs ───────────────────────────────────────────────────────────────────


@router.post("/programs", response_model=ProgramRead, status_code=201)
async def create_program(
    payload: ProgramCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> ProgramRead:
    program = await ProgramService(session).create(payload, session)
    return ProgramRead.model_validate(program)


@router.get("/programs", response_model=list[ProgramRead])
async def list_programs(
    department_id: UUID | None = Query(None),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[ProgramRead]:
    programs = await ProgramService(session).list(department_id)
    return [ProgramRead.model_validate(p) for p in programs]


@router.get("/programs/{program_id}", response_model=ProgramRead)
async def get_program(
    program_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> ProgramRead:
    program = await ProgramService(session).get(program_id)
    return ProgramRead.model_validate(program)


@router.put("/programs/{program_id}", response_model=ProgramRead)
async def update_program(
    program_id: UUID,
    payload: ProgramUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> ProgramRead:
    program = await ProgramService(session).update(program_id, payload)
    return ProgramRead.model_validate(program)


@router.get("/programs/{program_id}/curriculum", response_model=list[CurriculumCourseRead])
async def get_program_curriculum(
    program_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[CurriculumCourseRead]:
    curriculum = await ProgramService(session).get_curriculum(program_id, session)
    return [CurriculumCourseRead.model_validate(c) for c in curriculum]


@router.post(
    "/programs/{program_id}/curriculum", response_model=CurriculumCourseRead, status_code=201
)
async def add_to_curriculum(
    program_id: UUID,
    payload: CurriculumCourseCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> CurriculumCourseRead:
    cc = await ProgramService(session).add_to_curriculum(program_id, payload, session)
    return CurriculumCourseRead.model_validate(cc)


@router.delete("/programs/{program_id}/curriculum/{cc_id}", status_code=204)
async def remove_from_curriculum(
    program_id: UUID,
    cc_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> None:
    await ProgramService(session).remove_from_curriculum(cc_id, session)


# ── Semesters ──────────────────────────────────────────────────────────────────


@router.post("/semesters", response_model=SemesterRead, status_code=201)
async def create_semester(
    payload: SemesterCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> SemesterRead:
    semester = await SemesterService(session).create(payload)
    return SemesterRead.model_validate(semester)


@router.get("/semesters", response_model=list[SemesterRead])
async def list_semesters(
    academic_year: str | None = Query(None),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[SemesterRead]:
    semesters = await SemesterService(session).list(academic_year)
    return [SemesterRead.model_validate(s) for s in semesters]


@router.get("/semesters/{semester_id}", response_model=SemesterRead)
async def get_semester(
    semester_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> SemesterRead:
    semester = await SemesterService(session).get(semester_id)
    return SemesterRead.model_validate(semester)


@router.put("/semesters/{semester_id}", response_model=SemesterRead)
async def update_semester(
    semester_id: UUID,
    payload: SemesterUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> SemesterRead:
    semester = await SemesterService(session).update(semester_id, payload)
    return SemesterRead.model_validate(semester)


@router.patch("/semesters/{semester_id}/activate", response_model=SemesterRead)
async def activate_semester(
    semester_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> SemesterRead:
    semester = await SemesterService(session).activate(semester_id)
    return SemesterRead.model_validate(semester)
