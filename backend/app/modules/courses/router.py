from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.courses.schemas import (
    AssignLecturerRequest,
    CourseCreate,
    CourseMaterialCreate,
    CourseMaterialRead,
    CourseRead,
    CourseUpdate,
    PrerequisiteCreate,
    PrerequisiteRead,
    TimetableEntryCreate,
    TimetableEntryRead,
)
from app.modules.courses.service import (
    CourseMaterialService,
    CourseService,
    PrerequisiteService,
    TimetableService,
)
from app.modules.students.schemas import StudentRead

router = APIRouter()

# ── Courses ────────────────────────────────────────────────────────────────────


@router.post("", response_model=CourseRead, status_code=201)
async def create_course(
    payload: CourseCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> CourseRead:
    course = await CourseService(session).create(payload)
    return CourseRead.model_validate(course)


@router.get("", response_model=list[CourseRead])
async def list_courses(
    program_id: UUID | None = Query(None),
    semester_id: UUID | None = Query(None),
    lecturer_id: UUID | None = Query(None),
    status: str | None = Query(None),
    limit: int = Query(100, le=500),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[CourseRead]:
    courses = await CourseService(session).list(
        program_id, semester_id, lecturer_id, status, limit, offset
    )
    return [CourseRead.model_validate(c) for c in courses]


@router.get("/{course_id}", response_model=CourseRead)
async def get_course(
    course_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> CourseRead:
    course = await CourseService(session).get(course_id)
    return CourseRead.model_validate(course)


@router.put("/{course_id}", response_model=CourseRead)
async def update_course(
    course_id: UUID,
    payload: CourseUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> CourseRead:
    course = await CourseService(session).update(course_id, payload)
    return CourseRead.model_validate(course)


@router.patch("/{course_id}/syllabus", response_model=CourseRead)
async def set_syllabus(
    course_id: UUID,
    syllabus_path: str,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "LECTURER")),
) -> CourseRead:
    course = await CourseService(session).set_syllabus(course_id, syllabus_path)
    return CourseRead.model_validate(course)


@router.patch("/{course_id}/assign-lecturer", response_model=CourseRead)
async def assign_lecturer(
    course_id: UUID,
    payload: AssignLecturerRequest,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> CourseRead:
    course = await CourseService(session).assign_lecturer(course_id, payload)
    return CourseRead.model_validate(course)


@router.get("/{course_id}/students", response_model=list[StudentRead])
async def get_course_students(
    course_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "LECTURER")),
) -> list[StudentRead]:
    students = await CourseService(session).get_enrolled_students(course_id)
    return [StudentRead.model_validate(s) for s in students]


# ── Prerequisites ──────────────────────────────────────────────────────────────


@router.post("/{course_id}/prerequisites", response_model=PrerequisiteRead, status_code=201)
async def add_prerequisite(
    course_id: UUID,
    payload: PrerequisiteCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> PrerequisiteRead:
    prereq = await PrerequisiteService(session).add(course_id, payload)
    return PrerequisiteRead.model_validate(prereq)


@router.get("/{course_id}/prerequisites", response_model=list[PrerequisiteRead])
async def list_prerequisites(
    course_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[PrerequisiteRead]:
    prereqs = await PrerequisiteService(session).list(course_id)
    return [PrerequisiteRead.model_validate(p) for p in prereqs]


@router.delete("/{course_id}/prerequisites/{prereq_id}", status_code=204)
async def remove_prerequisite(
    course_id: UUID,
    prereq_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> None:
    await PrerequisiteService(session).remove(prereq_id)


# ── Materials ──────────────────────────────────────────────────────────────────


@router.post("/{course_id}/materials", response_model=CourseMaterialRead, status_code=201)
async def add_material(
    course_id: UUID,
    payload: CourseMaterialCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "LECTURER")),
) -> CourseMaterialRead:
    material = await CourseMaterialService(session).add(course_id, payload, current_user.user_id)
    return CourseMaterialRead.model_validate(material)


@router.get("/{course_id}/materials", response_model=list[CourseMaterialRead])
async def list_materials(
    course_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[CourseMaterialRead]:
    materials = await CourseMaterialService(session).list(course_id)
    return [CourseMaterialRead.model_validate(m) for m in materials]


@router.delete("/{course_id}/materials/{material_id}", status_code=204)
async def remove_material(
    course_id: UUID,
    material_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "LECTURER")),
) -> None:
    await CourseMaterialService(session).remove(material_id)


# ── Timetable ──────────────────────────────────────────────────────────────────


@router.post("/{course_id}/timetable", response_model=TimetableEntryRead, status_code=201)
async def add_timetable_entry(
    course_id: UUID,
    payload: TimetableEntryCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> TimetableEntryRead:
    entry = await TimetableService(session).add(course_id, payload)
    return TimetableEntryRead.model_validate(entry)


@router.get("/{course_id}/timetable", response_model=list[TimetableEntryRead])
async def list_timetable(
    course_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[TimetableEntryRead]:
    entries = await TimetableService(session).list(course_id)
    return [TimetableEntryRead.model_validate(e) for e in entries]
