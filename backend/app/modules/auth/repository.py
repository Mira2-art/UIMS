from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import (
    ClientApp,
    PasswordResetToken,
    Permission,
    Role,
    RolePermission,
    User,
    UserRole,
    UserSession,
)


class UserRepository(AsyncRepository[User]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, User)

    async def get_by_email(self, email: str) -> User | None:
        result = await self.session.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()

    async def exists_by_email(self, email: str) -> bool:
        result = await self.session.execute(select(User.user_id).where(User.email == email))
        return result.scalar_one_or_none() is not None


class UserSessionRepository(AsyncRepository[UserSession]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, UserSession)

    async def revoke(self, session_id: UUID) -> None:
        await self.session.execute(
            update(UserSession)
            .where(UserSession.session_id == session_id)
            .values(revoked_at=datetime.now(UTC))
        )
        await self.session.commit()

    async def get_active_by_jti(self, jti: str) -> UserSession | None:
        result = await self.session.execute(
            select(UserSession).where(
                UserSession.token_jti == jti,
                UserSession.revoked_at.is_(None),
                UserSession.expires_at > datetime.now(UTC),
            )
        )
        return result.scalar_one_or_none()


class PasswordResetTokenRepository(AsyncRepository[PasswordResetToken]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, PasswordResetToken)

    async def get_valid_by_hash(self, token_hash: str) -> PasswordResetToken | None:
        result = await self.session.execute(
            select(PasswordResetToken).where(
                PasswordResetToken.token_hash == token_hash,
                PasswordResetToken.used_at.is_(None),
                PasswordResetToken.expires_at > datetime.now(UTC),
            )
        )
        return result.scalar_one_or_none()

    async def mark_used(self, token_id: UUID) -> None:
        await self.session.execute(
            update(PasswordResetToken)
            .where(PasswordResetToken.token_id == token_id)
            .values(used_at=datetime.now(UTC))
        )
        await self.session.commit()


class ClientAppRepository(AsyncRepository[ClientApp]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, ClientApp)

    async def get_by_client_id(self, client_id: str) -> ClientApp | None:
        result = await self.session.execute(
            select(ClientApp).where(ClientApp.client_id == client_id)
        )
        return result.scalar_one_or_none()

    async def get_active(self, client_id: str) -> ClientApp | None:
        result = await self.session.execute(
            select(ClientApp).where(
                ClientApp.client_id == client_id,
                ClientApp.is_active.is_(True),
            )
        )
        return result.scalar_one_or_none()


class RoleRepository(AsyncRepository[Role]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Role)

    async def get_by_code(self, role_code: str) -> Role | None:
        result = await self.session.execute(select(Role).where(Role.role_code == role_code))
        return result.scalar_one_or_none()


class PermissionRepository(AsyncRepository[Permission]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Permission)


class RolePermissionRepository(AsyncRepository[RolePermission]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, RolePermission)

    async def get_assignment(self, role_id: UUID, permission_id: UUID) -> RolePermission | None:
        result = await self.session.execute(
            select(RolePermission).where(
                RolePermission.role_id == role_id,
                RolePermission.permission_id == permission_id,
            )
        )
        return result.scalar_one_or_none()


class UserRoleRepository(AsyncRepository[UserRole]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, UserRole)

    async def get_roles_for_user(self, user_id: UUID) -> list[Role]:
        result = await self.session.execute(
            select(Role)
            .join(UserRole, UserRole.role_id == Role.role_id)
            .where(UserRole.user_id == user_id)
        )
        return list(result.scalars().all())

    async def get_assignment(self, user_id: UUID, role_id: UUID) -> UserRole | None:
        result = await self.session.execute(
            select(UserRole).where(
                UserRole.user_id == user_id,
                UserRole.role_id == role_id,
            )
        )
        return result.scalar_one_or_none()
