from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.attendance.schemas import (
    AttendanceRecordRead,
    AttendanceSessionCreate,
    AttendanceSessionRead,
    BulkAttendanceRequest,
    StudentAttendanceSummary,
)
from app.modules.attendance.service import AttendanceService

router = APIRouter()


@router.post("/sessions", response_model=AttendanceSessionRead, status_code=201)
async def create_session(
    payload: AttendanceSessionCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "LECTURER")),
) -> AttendanceSessionRead:
    att_session = await AttendanceService(session).create_session(payload, current_user.user_id)
    return AttendanceSessionRead.model_validate(att_session)


@router.get("/sessions", response_model=list[AttendanceSessionRead])
async def list_sessions(
    course_id: UUID = Query(...),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[AttendanceSessionRead]:
    sessions = await AttendanceService(session).list_sessions(course_id)
    return [AttendanceSessionRead.model_validate(s) for s in sessions]


@router.post("/sessions/{session_id}/records", response_model=list[AttendanceRecordRead])
async def bulk_record(
    session_id: UUID,
    payload: BulkAttendanceRequest,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "LECTURER")),
) -> list[AttendanceRecordRead]:
    records = await AttendanceService(session).bulk_record(
        session_id, payload, current_user.user_id
    )
    return [AttendanceRecordRead.model_validate(r) for r in records]


@router.get("/sessions/{session_id}/records", response_model=list[AttendanceRecordRead])
async def get_session_records(
    session_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[AttendanceRecordRead]:
    records = await AttendanceService(session).get_session_records(session_id)
    return [AttendanceRecordRead.model_validate(r) for r in records]


@router.get("/students/{student_id}/summary", response_model=StudentAttendanceSummary)
async def get_student_attendance(
    student_id: UUID,
    course_id: UUID = Query(...),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> StudentAttendanceSummary:
    return await AttendanceService(session).get_student_summary(student_id, course_id)
