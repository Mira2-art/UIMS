from uuid import UUID

from fastapi import APIRouter, Depends, Header, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.auth.schemas import (
    AssignPermissionRequest,
    AssignRoleRequest,
    ChangePasswordRequest,
    ClientAppCreate,
    ClientAppRead,
    ForgotPasswordRequest,
    LoginRequest,
    PermissionCreate,
    PermissionRead,
    RefreshRequest,
    RegisterRequest,
    ResetPasswordRequest,
    RoleCreate,
    RoleRead,
    TokenPair,
    UserRead,
    VerifyEmailConfirm,
)
from app.modules.auth.service import AuthService

router = APIRouter()

# ── Public auth (no token, but client_id required in body) ────────────────────


@router.post("/register", response_model=UserRead, status_code=201)
async def register(
    payload: RegisterRequest,
    request: Request,
    session: AsyncSession = Depends(db_session),
) -> UserRead:
    """
    Register a new user account.

    Requires `client_id` (registered app identifier) and `device_info` in the body.
    The `client_id` is validated against the registered client apps before account creation.
    """
    ip = request.client.host if request.client else None
    return await AuthService(session).register(payload, ip)


@router.post("/login", response_model=TokenPair)
async def login(
    payload: LoginRequest,
    request: Request,
    session: AsyncSession = Depends(db_session),
) -> TokenPair:
    """
    Authenticate with email, password, client_id and device_info.

    Returns an `access_token` (30 min) and `refresh_token` (7 days).
    Both tokens carry the `cid` (client_id) claim.
    All subsequent requests must include `X-Client-ID: <client_id>` header.
    """
    ip = request.client.host if request.client else None
    ua = request.headers.get("user-agent")
    return await AuthService(session).login(payload, ip, ua)


@router.post("/refresh", response_model=TokenPair)
async def refresh_token(
    payload: RefreshRequest,
    x_client_id: str | None = Header(default=None, alias="X-Client-ID"),
    session: AsyncSession = Depends(db_session),
) -> TokenPair:
    """
    Exchange a refresh token for a new token pair.
    `X-Client-ID` header is verified against the token's `cid` claim.
    """
    return await AuthService(session).refresh(payload.refresh_token, x_client_id)


@router.post("/forgot-password")
async def forgot_password(
    payload: ForgotPasswordRequest,
    session: AsyncSession = Depends(db_session),
) -> dict[str, str]:
    reset_token = await AuthService(session).forgot_password(payload)
    return {"detail": "Reset token issued", "reset_token": reset_token}


@router.post("/reset-password", status_code=204)
async def reset_password(
    payload: ResetPasswordRequest,
    session: AsyncSession = Depends(db_session),
) -> None:
    await AuthService(session).reset_password(payload)


# ── Authenticated (token + X-Client-ID header required) ───────────────────────


@router.post("/logout", status_code=204)
async def logout(
    session_id: UUID,
    request: Request,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(get_current_user),
) -> None:
    await AuthService(session).logout(session_id, current_user.user_id)


@router.post("/change-password", status_code=204)
async def change_password(
    payload: ChangePasswordRequest,
    request: Request,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(get_current_user),
) -> None:
    ip = request.client.host if request.client else None
    await AuthService(session).change_password(current_user.user_id, payload, ip)


@router.post("/send-verification")
async def send_verification_email(
    session: AsyncSession = Depends(db_session),
    current_user=Depends(get_current_user),
) -> dict[str, str]:
    token = await AuthService(session).send_verification_email(current_user.user_id)
    return {"detail": "Verification token issued", "verification_token": token}


@router.post("/verify-email", response_model=UserRead)
async def verify_email(
    payload: VerifyEmailConfirm,
    session: AsyncSession = Depends(db_session),
) -> UserRead:
    return await AuthService(session).confirm_email(payload.token)


# ── Role & Permission management (ADMIN / SUPER_ADMIN) ────────────────────────


@router.get("/roles", response_model=list[RoleRead])
async def list_roles(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> list[RoleRead]:
    roles = await AuthService(session).list_roles()
    return [RoleRead.model_validate(r) for r in roles]


@router.post("/roles", response_model=RoleRead, status_code=201)
async def create_role(
    payload: RoleCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> RoleRead:
    role = await AuthService(session).create_role(payload)
    return RoleRead.model_validate(role)


@router.get("/permissions", response_model=list[PermissionRead])
async def list_permissions(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> list[PermissionRead]:
    perms = await AuthService(session).list_permissions()
    return [PermissionRead.model_validate(p) for p in perms]


@router.post("/permissions", response_model=PermissionRead, status_code=201)
async def create_permission(
    payload: PermissionCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("SUPER_ADMIN")),
) -> PermissionRead:
    perm = await AuthService(session).create_permission(payload)
    return PermissionRead.model_validate(perm)


@router.post("/roles/{role_id}/permissions", status_code=204)
async def assign_permission_to_role(
    role_id: UUID,
    payload: AssignPermissionRequest,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> None:
    await AuthService(session).assign_permission_to_role(role_id, payload.permission_id)


@router.post("/users/{user_id}/roles", status_code=204)
async def assign_role_to_user(
    user_id: UUID,
    payload: AssignRoleRequest,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> None:
    await AuthService(session).assign_role_to_user(user_id, payload.role_id, current_user.user_id)


@router.delete("/users/{user_id}/roles/{role_id}", status_code=204)
async def remove_role_from_user(
    user_id: UUID,
    role_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> None:
    await AuthService(session).remove_role_from_user(user_id, role_id)


# ── Client App management (SUPER_ADMIN) ────────────────────────────────────────


@router.get("/clients", response_model=list[ClientAppRead])
async def list_client_apps(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("SUPER_ADMIN")),
) -> list[ClientAppRead]:
    """List all registered client applications."""
    apps = await AuthService(session).list_client_apps()
    return [ClientAppRead.model_validate(a) for a in apps]


@router.post("/clients", response_model=ClientAppRead, status_code=201)
async def create_client_app(
    payload: ClientAppCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("SUPER_ADMIN")),
) -> ClientAppRead:
    """
    Register a new client application.

    Generates a cryptographically random `client_id` (43-char URL-safe base64,
    same approach as Rails' `has_secure_token`). Store this value securely in
    the client app's config — it cannot be recovered after this response.
    """
    app = await AuthService(session).create_client_app(payload)
    return ClientAppRead.model_validate(app)


@router.post("/clients/{client_app_id}/rotate", response_model=ClientAppRead)
async def rotate_client_id(
    client_app_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("SUPER_ADMIN")),
) -> ClientAppRead:
    """
    Rotate the `client_id` for an app — generates a new one, invalidating the old one.
    All active sessions from this client will fail on next request.
    """
    app = await AuthService(session).rotate_client_id(client_app_id)
    return ClientAppRead.model_validate(app)


@router.patch("/clients/{client_app_id}/deactivate", response_model=ClientAppRead)
async def deactivate_client_app(
    client_app_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("SUPER_ADMIN")),
) -> ClientAppRead:
    """Block all requests from this client app immediately."""
    app = await AuthService(session).toggle_client_app(client_app_id, is_active=False)
    return ClientAppRead.model_validate(app)


@router.patch("/clients/{client_app_id}/activate", response_model=ClientAppRead)
async def activate_client_app(
    client_app_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("SUPER_ADMIN")),
) -> ClientAppRead:
    """Re-enable a previously deactivated client app."""
    app = await AuthService(session).toggle_client_app(client_app_id, is_active=True)
    return ClientAppRead.model_validate(app)


@router.post("/clients/seed", response_model=list[ClientAppRead], status_code=201)
async def seed_default_clients(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("SUPER_ADMIN")),
) -> list[ClientAppRead]:
    """
    Idempotently create the 4 default client apps:
    - Web Admin (web)
    - Mobile Student (ios/android)
    - Mobile Staff (ios/android)
    - Web Public (web)

    Safe to call multiple times — already-existing apps are skipped.
    """
    apps = await AuthService(session).seed_default_clients()
    return [ClientAppRead.model_validate(a) for a in apps]
