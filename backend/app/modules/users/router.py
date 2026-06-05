from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.users.schemas import StatusUpdate, UserRead, UserUpdate
from app.modules.users.service import UserService

router = APIRouter()


# ── Own profile (all authenticated users) ─────────────────────────────────────


@router.get("/me", response_model=UserRead)
async def get_me(current_user=Depends(get_current_user)) -> UserRead:
    return UserRead.model_validate(current_user)


# ── User management (ADMIN / SUPER_ADMIN) ─────────────────────────────────────


@router.get("", response_model=list[UserRead])
async def list_users(
    status: str | None = Query(None),
    limit: int = Query(100, le=500),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> list[UserRead]:
    users = await UserService(session).list(status, limit, offset)
    return [UserRead.model_validate(u) for u in users]


@router.get("/{user_id}", response_model=UserRead)
async def get_user(
    user_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "HR")),
) -> UserRead:
    user = await UserService(session).get(user_id)
    return UserRead.model_validate(user)


@router.put("/{user_id}", response_model=UserRead)
async def update_user(
    user_id: UUID,
    payload: UserUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> UserRead:
    user = await UserService(session).update(user_id, payload)
    return UserRead.model_validate(user)


@router.patch("/{user_id}/status", response_model=UserRead)
async def update_user_status(
    user_id: UUID,
    payload: StatusUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> UserRead:
    user = await UserService(session).update_status(user_id, payload)
    return UserRead.model_validate(user)


@router.delete("/{user_id}", status_code=204)
async def delete_user(
    user_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("SUPER_ADMIN")),
) -> None:
    await UserService(session).delete(user_id)
