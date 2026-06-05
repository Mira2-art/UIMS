from __future__ import annotations

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import User, UserStatus
from app.modules.auth.repository import UserRepository
from app.modules.users.schemas import StatusUpdate, UserUpdate


class UserService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = UserRepository(session)

    async def list(
        self,
        user_status: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[User]:
        from sqlalchemy import select

        query = select(User)
        if user_status:
            query = query.where(User.status == user_status)
        result = await self.repo.session.execute(query.offset(offset).limit(limit))
        return list(result.scalars().all())

    async def get(self, user_id: UUID) -> User:
        return await self.repo.get_or_404(user_id)

    async def update(self, user_id: UUID, payload: UserUpdate) -> User:
        user = await self.repo.get_or_404(user_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(user, field, value)
        return await self.repo.update(user)

    async def update_status(self, user_id: UUID, payload: StatusUpdate) -> User:
        try:
            new_status = UserStatus(payload.status)
        except ValueError as exc:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, f"Invalid status: {payload.status}"
            ) from exc
        user = await self.repo.get_or_404(user_id)
        user.status = new_status
        return await self.repo.update(user)

    async def delete(self, user_id: UUID) -> None:
        user = await self.repo.get_or_404(user_id)
        user.status = UserStatus.INACTIVE
        await self.repo.update(user)
