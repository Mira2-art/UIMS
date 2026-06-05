from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import _get_user_role_codes, db_session, get_current_user, require_roles
from app.modules.enrollments.schemas import (
    DropEnrollmentRequest,
    EnrollmentCreate,
    EnrollmentRead,
    WithdrawRequest,
)
from app.modules.enrollments.service import EnrollmentService

router = APIRouter()


# ── Enroll — ADMIN / REGISTRAR can enroll anyone; STUDENT can self-enroll ─────


@router.post("", response_model=EnrollmentRead, status_code=201)
async def create_enrollment(
    payload: EnrollmentCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "STUDENT")),
) -> EnrollmentRead:
    if not payload.enrolled_by:
        payload.enrolled_by = current_user.user_id
    roles = await _get_user_role_codes(current_user.user_id, session)
    enforce_window = "STUDENT" in roles and not roles.intersection(
        {"ADMIN", "SUPER_ADMIN", "REGISTRAR"}
    )
    enrollment = await EnrollmentService(session).create(payload, enforce_window=enforce_window)
    return EnrollmentRead.model_validate(enrollment)


@router.get("", response_model=list[EnrollmentRead])
async def list_enrollments(
    student_id: UUID | None = Query(None),
    course_id: UUID | None = Query(None),
    status: str | None = Query(None),
    limit: int = Query(100, le=500),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[EnrollmentRead]:
    enrollments = await EnrollmentService(session).list(
        student_id, course_id, status, limit, offset
    )
    return [EnrollmentRead.model_validate(e) for e in enrollments]


@router.get("/{enrollment_id}", response_model=EnrollmentRead)
async def get_enrollment(
    enrollment_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> EnrollmentRead:
    enrollment = await EnrollmentService(session).get(enrollment_id)
    return EnrollmentRead.model_validate(enrollment)


# ── Status transitions ─────────────────────────────────────────────────────────


@router.patch("/{enrollment_id}/drop", response_model=EnrollmentRead)
async def drop_enrollment(
    enrollment_id: UUID,
    payload: DropEnrollmentRequest,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "STUDENT")),
) -> EnrollmentRead:
    enrollment = await EnrollmentService(session).drop(enrollment_id, payload)
    return EnrollmentRead.model_validate(enrollment)


@router.patch("/{enrollment_id}/withdraw", response_model=EnrollmentRead)
async def withdraw_enrollment(
    enrollment_id: UUID,
    payload: WithdrawRequest,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> EnrollmentRead:
    enrollment = await EnrollmentService(session).withdraw(enrollment_id, payload)
    return EnrollmentRead.model_validate(enrollment)


@router.patch("/{enrollment_id}/complete", response_model=EnrollmentRead)
async def complete_enrollment(
    enrollment_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> EnrollmentRead:
    enrollment = await EnrollmentService(session).complete(enrollment_id)
    return EnrollmentRead.model_validate(enrollment)
