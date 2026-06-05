from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.courses.schemas import CourseRead
from app.modules.teachers.schemas import LecturerCreate, LecturerRead, LecturerUpdate
from app.modules.teachers.service import LecturerService

router = APIRouter()


@router.post("", response_model=LecturerRead, status_code=201)
async def create_lecturer(
    payload: LecturerCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "HR")),
) -> LecturerRead:
    lecturer = await LecturerService(session).create(payload)
    return LecturerRead.model_validate(lecturer)


@router.get("", response_model=list[LecturerRead])
async def list_lecturers(
    department_id: UUID | None = Query(None),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[LecturerRead]:
    lecturers = await LecturerService(session).list(department_id)
    return [LecturerRead.model_validate(lec) for lec in lecturers]


@router.get("/{lecturer_id}", response_model=LecturerRead)
async def get_lecturer(
    lecturer_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> LecturerRead:
    lecturer = await LecturerService(session).get(lecturer_id)
    return LecturerRead.model_validate(lecturer)


@router.put("/{lecturer_id}", response_model=LecturerRead)
async def update_lecturer(
    lecturer_id: UUID,
    payload: LecturerUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "HR")),
) -> LecturerRead:
    lecturer = await LecturerService(session).update(lecturer_id, payload)
    return LecturerRead.model_validate(lecturer)


@router.get("/{lecturer_id}/courses", response_model=list[CourseRead])
async def get_lecturer_courses(
    lecturer_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[CourseRead]:
    courses = await LecturerService(session).get_courses(lecturer_id)
    return [CourseRead.model_validate(c) for c in courses]
