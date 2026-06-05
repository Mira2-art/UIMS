from collections.abc import AsyncGenerator
from uuid import UUID

from fastapi import Depends, Header, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import decode_access_token
from app.db.session import get_db

_bearer = HTTPBearer(auto_error=True)

# Roles that can access any student's data without ownership check
_STAFF_ROLES = {"SUPER_ADMIN", "ADMIN", "REGISTRAR", "LECTURER", "FINANCE", "STAFF", "HR"}


async def db_session() -> AsyncGenerator[AsyncSession, None]:
    async for session in get_db():
        yield session


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer),
    x_client_id: str | None = Header(default=None, alias="X-Client-ID"),
    session: AsyncSession = Depends(db_session),
):
    from sqlalchemy import select

    from app.db.sis_models import ClientApp, User, UserSession

    token = credentials.credentials
    try:
        payload = decode_access_token(token)
    except JWTError as exc:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid or expired token") from exc

    if payload.get("type") != "access":
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Token type mismatch")

    user_id_str: str | None = payload.get("sub")
    jti: str | None = payload.get("jti")
    token_client_id: str | None = payload.get("cid")

    if not user_id_str:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token payload")

    # ── Client-ID header validation ────────────────────────────────────────────
    if not x_client_id:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            "Missing X-Client-ID header",
        )

    # Verify the header client_id is registered and active
    client_result = await session.execute(
        select(ClientApp).where(
            ClientApp.client_id == x_client_id,
            ClientApp.is_active.is_(True),
        )
    )
    if client_result.scalar_one_or_none() is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid or inactive X-Client-ID")

    # If token carries a client_id claim, it must match the header
    if token_client_id and token_client_id != x_client_id:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            "X-Client-ID does not match token client",
        )

    # ── Session validation ─────────────────────────────────────────────────────
    if jti:
        from datetime import UTC, datetime

        result = await session.execute(
            select(UserSession).where(
                UserSession.token_jti == jti,
                UserSession.revoked_at.is_(None),
                UserSession.expires_at > datetime.now(UTC),
            )
        )
        db_session_row = result.scalar_one_or_none()
        if db_session_row is None:
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Session revoked or expired")

        # Ensure the session's client_id also matches (blocks token reuse across clients)
        if db_session_row.client_id and db_session_row.client_id != x_client_id:
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Client mismatch on session")

    user = await session.get(User, UUID(user_id_str))
    if user is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "User not found")
    return user


async def _get_user_role_codes(user_id: UUID, session: AsyncSession) -> set[str]:
    from sqlalchemy import select

    from app.db.sis_models import Role, UserRole

    result = await session.execute(
        select(Role)
        .join(UserRole, UserRole.role_id == Role.role_id)
        .where(UserRole.user_id == user_id)
    )
    return {r.role_code for r in result.scalars().all()}


def require_roles(*role_codes: str):
    async def _check(
        current_user=Depends(get_current_user),
        session: AsyncSession = Depends(db_session),
    ):
        user_role_codes = await _get_user_role_codes(current_user.user_id, session)
        if not user_role_codes.intersection(set(role_codes)):
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Insufficient permissions")
        return current_user

    return _check


def own_student_or_roles(*fallback_roles: str):
    """Allow if current user owns the student record OR has one of the fallback roles."""

    async def _check(
        request: Request,
        current_user=Depends(get_current_user),
        session: AsyncSession = Depends(db_session),
    ):
        from app.db.sis_models import Student

        user_role_codes = await _get_user_role_codes(current_user.user_id, session)
        if user_role_codes.intersection(set(fallback_roles)):
            return current_user

        student_id_str = request.path_params.get("student_id")
        if student_id_str:
            student = await session.get(Student, UUID(student_id_str))
            if student and student.user_id == current_user.user_id:
                return current_user

        raise HTTPException(status.HTTP_403_FORBIDDEN, "Access denied")

    return _check
