from __future__ import annotations

from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import (
    Announcement,
    AnnouncementTarget,
    Notification,
    NotificationType,
    PriorityLevel,
)
from app.modules.communication.repository import (
    AnnouncementRepository,
    EmailLogRepository,
    NotificationRepository,
)
from app.modules.communication.schemas import (
    AnnouncementCreate,
    BroadcastRequest,
    SendNotificationRequest,
)


class AnnouncementService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = AnnouncementRepository(session)

    async def create(self, payload: AnnouncementCreate, author_id: UUID) -> Announcement:
        try:
            target_type = AnnouncementTarget(payload.target_type)
            priority = PriorityLevel(payload.priority)
        except ValueError as exc:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, str(exc)) from exc
        announcement = Announcement(
            title=payload.title,
            content=payload.content,
            author_id=author_id,
            target_type=target_type,
            target_id=payload.target_id,
            priority=priority,
            is_pinned=payload.is_pinned,
            is_urgent=payload.is_urgent,
            expires_at=payload.expires_at,
        )
        return await self.repo.create(announcement)

    async def list(
        self,
        target_type: str | None = None,
        target_id: UUID | None = None,
        published_only: bool = False,
    ) -> list:
        query = select(Announcement).order_by(
            Announcement.is_pinned.desc(), Announcement.created_at.desc()
        )
        if target_type:
            query = query.where(Announcement.target_type == target_type)
        if target_id:
            query = query.where(Announcement.target_id == target_id)
        if published_only:
            query = query.where(Announcement.published_at.is_not(None))
        result = await self.repo.session.execute(query)
        return list(result.scalars().all())

    async def get(self, announcement_id: UUID) -> Announcement:
        announcement = await self.repo.get_or_404(announcement_id)
        announcement.view_count += 1
        await self.repo.update(announcement)
        return announcement

    async def publish(self, announcement_id: UUID) -> Announcement:
        announcement = await self.repo.get_or_404(announcement_id)
        announcement.published_at = datetime.now(UTC)
        return await self.repo.update(announcement)


class NotificationService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = NotificationRepository(session)

    async def send(self, payload: SendNotificationRequest) -> list[Notification]:
        try:
            notif_type = NotificationType(payload.notification_type)
        except ValueError as exc:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Invalid notification type: {payload.notification_type}",
            ) from exc
        created: list[Notification] = []
        for user_id in payload.user_ids:
            notif = Notification(
                user_id=user_id,
                title=payload.title,
                message=payload.message,
                notification_type=notif_type,
                reference_type=payload.reference_type,
                reference_id=payload.reference_id,
                action_url=payload.action_url,
                is_read=False,
            )
            created.append(await self.repo.create(notif))
        return created

    async def broadcast_to_roles(
        self, payload: BroadcastRequest, session: AsyncSession
    ) -> list[Notification]:
        from app.db.sis_models import Role, User, UserRole

        try:
            notif_type = NotificationType(payload.notification_type)
        except ValueError as exc:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Invalid notification type: {payload.notification_type}",
            ) from exc

        result = await session.execute(
            select(User.user_id)
            .join(UserRole, UserRole.user_id == User.user_id)
            .join(Role, Role.role_id == UserRole.role_id)
            .where(Role.role_code.in_(payload.role_codes))
            .distinct()
        )
        user_ids = [row[0] for row in result.all()]
        if not user_ids:
            return []

        created: list[Notification] = []
        for user_id in user_ids:
            notif = Notification(
                user_id=user_id,
                title=payload.title,
                message=payload.message,
                notification_type=notif_type,
                action_url=payload.action_url,
                is_read=False,
            )
            created.append(await self.repo.create(notif))
        return created

    async def list_for_user(self, user_id: UUID) -> list:
        return await self.repo.list_for_user(user_id)

    async def mark_read(self, notification_id: UUID, user_id: UUID) -> Notification:
        notif = await self.repo.get_or_404(notification_id)
        if notif.user_id != user_id:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Not your notification")
        notif.is_read = True
        notif.read_at = datetime.now(UTC)
        return await self.repo.update(notif)

    async def mark_all_read(self, user_id: UUID) -> None:
        await self.repo.mark_all_read(user_id)


class EmailLogService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = EmailLogRepository(session)

    async def list(self, limit: int = 100) -> list:
        return await self.repo.list(limit=limit)
