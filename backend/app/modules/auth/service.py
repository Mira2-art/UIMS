from __future__ import annotations

import hashlib
import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_access_token,
    hash_password,
    verify_password,
)
from app.db.sis_models import (
    AuditLog,
    ClientApp,
    PasswordResetToken,
    Permission,
    Role,
    RolePermission,
    User,
    UserRole,
    UserSession,
    UserStatus,
)
from app.modules.auth.repository import (
    ClientAppRepository,
    PasswordResetTokenRepository,
    PermissionRepository,
    RolePermissionRepository,
    RoleRepository,
    UserRepository,
    UserRoleRepository,
    UserSessionRepository,
)
from app.modules.auth.schemas import (
    ChangePasswordRequest,
    ClientAppCreate,
    ForgotPasswordRequest,
    LoginRequest,
    PermissionCreate,
    RegisterRequest,
    ResetPasswordRequest,
    RoleCreate,
    TokenPair,
    UserRead,
)


async def _audit(
    session: AsyncSession, user_id: UUID | None, action: str, ip: str | None = None
) -> None:
    log = AuditLog(user_id=user_id, action=action, entity_type="auth", ip_address=ip)
    session.add(log)
    await session.commit()


class AuthService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.user_repo = UserRepository(session)
        self.session_repo = UserSessionRepository(session)
        self.reset_repo = PasswordResetTokenRepository(session)
        self.role_repo = RoleRepository(session)
        self.perm_repo = PermissionRepository(session)
        self.role_perm_repo = RolePermissionRepository(session)
        self.user_role_repo = UserRoleRepository(session)
        self.client_repo = ClientAppRepository(session)

    async def _validate_client(self, client_id: str) -> ClientApp:
        client = await self.client_repo.get_active(client_id)
        if not client:
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid or inactive client_id")
        return client

    async def register(self, payload: RegisterRequest, ip: str | None = None) -> UserRead:
        await self._validate_client(payload.client_id)
        if await self.user_repo.exists_by_email(payload.email):
            raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")
        user = User(
            email=payload.email,
            password_hash=hash_password(payload.password),
            first_name=payload.first_name,
            last_name=payload.last_name,
            phone=payload.phone,
            status=UserStatus.PENDING,
        )
        user = await self.user_repo.create(user)
        await _audit(self.session, user.user_id, "USER_REGISTERED", ip)
        try:
            from app.tasks.email import send_welcome_email

            send_welcome_email(user.email, user.first_name)
        except Exception:
            pass
        return UserRead.model_validate(user)

    async def login(
        self,
        payload: LoginRequest,
        ip_address: str | None = None,
        user_agent: str | None = None,
    ) -> TokenPair:
        await self._validate_client(payload.client_id)

        user = await self.user_repo.get_by_email(payload.email)
        if not user or not verify_password(payload.password, user.password_hash):
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid credentials")
        if user.status == UserStatus.SUSPENDED:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Account suspended")

        jti = secrets.token_urlsafe(32)
        access_token = create_access_token(
            subject=str(user.user_id),
            jti=jti,
            client_id=payload.client_id,
        )
        refresh_token = create_refresh_token(
            subject=str(user.user_id),
            client_id=payload.client_id,
        )

        expires_at = datetime.now(UTC) + timedelta(minutes=settings.access_token_expire_minutes)
        device_dict = payload.device_info.model_dump() if payload.device_info else None
        db_sess = UserSession(
            user_id=user.user_id,
            token_jti=jti,
            client_id=payload.client_id,
            ip_address=ip_address,
            user_agent=user_agent,
            device_info=device_dict,
            expires_at=expires_at,
        )
        await self.session_repo.create(db_sess)
        await _audit(self.session, user.user_id, "USER_LOGIN", ip_address)
        return TokenPair(access_token=access_token, refresh_token=refresh_token)

    async def logout(self, session_id: UUID, user_id: UUID) -> None:
        await self.session_repo.revoke(session_id)
        await _audit(self.session, user_id, "USER_LOGOUT")

    async def refresh(self, token: str, header_client_id: str | None = None) -> TokenPair:
        from jose import JWTError

        try:
            payload = decode_access_token(token)
        except JWTError as exc:
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid refresh token") from exc

        if payload.get("type") != "refresh":
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Token is not a refresh token")

        token_client_id: str | None = payload.get("cid")
        if header_client_id and token_client_id and header_client_id != token_client_id:
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "client_id mismatch")

        user_id_str: str | None = payload.get("sub")
        if not user_id_str:
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token payload")

        user = await self.user_repo.get(UUID(user_id_str))
        if not user:
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "User not found")

        client_id = token_client_id or header_client_id
        jti = secrets.token_urlsafe(32)
        new_access = create_access_token(subject=str(user.user_id), jti=jti, client_id=client_id)
        new_refresh = create_refresh_token(subject=str(user.user_id), client_id=client_id)

        expires_at = datetime.now(UTC) + timedelta(minutes=settings.access_token_expire_minutes)
        db_sess = UserSession(
            user_id=user.user_id,
            token_jti=jti,
            client_id=client_id,
            expires_at=expires_at,
        )
        await self.session_repo.create(db_sess)
        return TokenPair(access_token=new_access, refresh_token=new_refresh)

    async def send_verification_email(self, user_id: UUID) -> str:
        user = await self.user_repo.get(user_id)
        if not user:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
        if user.email_verified:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Email is already verified")
        token = create_access_token(subject=str(user.user_id), expires_delta=timedelta(hours=24))
        try:
            from app.tasks.email import send_verification_email

            send_verification_email(user.email, user.first_name, token)
        except Exception:
            pass
        return token

    async def confirm_email(self, token: str) -> UserRead:
        from jose import JWTError

        try:
            payload = decode_access_token(token)
        except JWTError as exc:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "Invalid or expired verification token"
            ) from exc

        user_id_str: str | None = payload.get("sub")
        if not user_id_str:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Malformed token")

        user = await self.user_repo.get(UUID(user_id_str))
        if not user:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
        if user.email_verified:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Email already verified")

        user.email_verified = True
        user.status = UserStatus.ACTIVE
        user = await self.user_repo.update(user)
        await _audit(self.session, user.user_id, "EMAIL_VERIFIED")
        return UserRead.model_validate(user)

    async def forgot_password(self, payload: ForgotPasswordRequest) -> str:
        user = await self.user_repo.get_by_email(payload.email)
        if not user:
            return "If an account exists, a reset token will be sent"
        raw_token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(raw_token.encode()).hexdigest()
        reset = PasswordResetToken(
            user_id=user.user_id,
            token_hash=token_hash,
            expires_at=datetime.now(UTC) + timedelta(hours=1),
        )
        await self.reset_repo.create(reset)
        try:
            from app.tasks.email import send_password_reset_email

            send_password_reset_email(user.email, user.first_name, raw_token)
        except Exception:
            pass
        return raw_token

    async def reset_password(self, payload: ResetPasswordRequest) -> None:
        token_hash = hashlib.sha256(payload.token.encode()).hexdigest()
        reset = await self.reset_repo.get_valid_by_hash(token_hash)
        if not reset:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid or expired reset token")
        user = await self.user_repo.get(reset.user_id)
        if not user:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
        user.password_hash = hash_password(payload.new_password)
        await self.user_repo.update(user)
        await self.reset_repo.mark_used(reset.token_id)
        await _audit(self.session, user.user_id, "PASSWORD_RESET")

    async def change_password(
        self, user_id: UUID, payload: ChangePasswordRequest, ip: str | None = None
    ) -> None:
        user = await self.user_repo.get(user_id)
        if not user:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
        if not verify_password(payload.current_password, user.password_hash):
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Current password is incorrect")
        user.password_hash = hash_password(payload.new_password)
        await self.user_repo.update(user)
        await _audit(self.session, user_id, "PASSWORD_CHANGED", ip)

    # ── Roles & Permissions ────────────────────────────────────────────────────

    async def list_roles(self) -> list[Role]:
        return await self.role_repo.list()

    async def create_role(self, payload: RoleCreate) -> Role:
        role = Role(
            role_name=payload.role_name,
            role_code=payload.role_code,
            description=payload.description,
        )
        return await self.role_repo.create(role)

    async def list_permissions(self) -> list[Permission]:
        return await self.perm_repo.list()

    async def create_permission(self, payload: PermissionCreate) -> Permission:
        perm = Permission(
            permission_name=payload.permission_name,
            permission_code=payload.permission_code,
            module=payload.module,
            description=payload.description,
        )
        return await self.perm_repo.create(perm)

    async def assign_permission_to_role(self, role_id: UUID, permission_id: UUID) -> None:
        existing = await self.role_perm_repo.get_assignment(role_id, permission_id)
        if existing:
            raise HTTPException(status.HTTP_409_CONFLICT, "Permission already assigned to role")
        rp = RolePermission(role_id=role_id, permission_id=permission_id)
        await self.role_perm_repo.create(rp)

    async def assign_role_to_user(
        self, user_id: UUID, role_id: UUID, assigned_by: UUID | None = None
    ) -> None:
        existing = await self.user_role_repo.get_assignment(user_id, role_id)
        if existing:
            raise HTTPException(status.HTTP_409_CONFLICT, "Role already assigned to user")
        ur = UserRole(user_id=user_id, role_id=role_id, assigned_by=assigned_by)
        await self.user_role_repo.create(ur)

    async def remove_role_from_user(self, user_id: UUID, role_id: UUID) -> None:
        assignment = await self.user_role_repo.get_assignment(user_id, role_id)
        if not assignment:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Role assignment not found")
        await self.user_role_repo.delete(assignment)

    # ── Client App management ──────────────────────────────────────────────────

    async def create_client_app(self, payload: ClientAppCreate) -> ClientApp:
        client_id = secrets.token_urlsafe(32)  # 43-char URL-safe string, same length as Rails uid
        app = ClientApp(
            client_id=client_id,
            name=payload.name,
            platform=payload.platform,
            description=payload.description,
            is_active=True,
        )
        return await self.client_repo.create(app)

    async def list_client_apps(self) -> list[ClientApp]:
        return await self.client_repo.list()

    async def rotate_client_id(self, client_app_id: UUID) -> ClientApp:
        app = await self.client_repo.get_or_404(client_app_id)
        app.client_id = secrets.token_urlsafe(32)
        return await self.client_repo.update(app)

    async def toggle_client_app(self, client_app_id: UUID, is_active: bool) -> ClientApp:
        app = await self.client_repo.get_or_404(client_app_id)
        app.is_active = is_active
        return await self.client_repo.update(app)

    async def seed_default_clients(self) -> list[ClientApp]:
        """Idempotently ensure the 4 default client apps exist."""
        defaults = [
            {"name": "Web Admin", "platform": "web", "description": "Admin/staff web dashboard"},
            {
                "name": "Mobile Student",
                "platform": "ios/android",
                "description": "Student mobile app",
            },
            {
                "name": "Mobile Staff",
                "platform": "ios/android",
                "description": "Lecturer/staff mobile app",
            },
            {"name": "Web Public", "platform": "web", "description": "Public-facing web portal"},
        ]
        from sqlalchemy import select

        result = await self.session.execute(select(ClientApp))
        existing_names = {a.name for a in result.scalars().all()}
        created: list[ClientApp] = []
        for d in defaults:
            if d["name"] not in existing_names:
                app = ClientApp(
                    client_id=secrets.token_urlsafe(32),
                    name=d["name"],
                    platform=d["platform"],
                    description=d["description"],
                    is_active=True,
                )
                self.session.add(app)
                created.append(app)
        if created:
            await self.session.commit()
            for a in created:
                await self.session.refresh(a)
        result2 = await self.session.execute(select(ClientApp))
        return list(result2.scalars().all())
