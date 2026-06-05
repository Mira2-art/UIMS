from __future__ import annotations

from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import Announcement, EmailLog, Notification


class AnnouncementRepository(AsyncRepository[Announcement]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Announcement)


class NotificationRepository(AsyncRepository[Notification]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Notification)

    async def list_for_user(self, user_id: UUID, limit: int = 50) -> list[Notification]:
        result = await self.session.execute(
            select(Notification)
            .where(Notification.user_id == user_id)
            .order_by(Notification.created_at.desc())
            .limit(limit)
        )
        return list(result.scalars().all())

    async def mark_all_read(self, user_id: UUID) -> None:
        from datetime import UTC, datetime

        await self.session.execute(
            update(Notification)
            .where(Notification.user_id == user_id, Notification.is_read.is_(False))
            .values(is_read=True, read_at=datetime.now(UTC))
        )
        await self.session.commit()


class EmailLogRepository(AsyncRepository[EmailLog]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, EmailLog)
