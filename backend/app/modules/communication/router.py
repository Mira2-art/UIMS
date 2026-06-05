from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.communication.schemas import (
    AnnouncementCreate,
    AnnouncementRead,
    BroadcastRequest,
    EmailLogRead,
    NotificationRead,
    SendNotificationRequest,
)
from app.modules.communication.service import (
    AnnouncementService,
    EmailLogService,
    NotificationService,
)

router = APIRouter()

# ── Announcements ──────────────────────────────────────────────────────────────


@router.post("/announcements", response_model=AnnouncementRead, status_code=201)
async def create_announcement(
    payload: AnnouncementCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "STAFF")),
) -> AnnouncementRead:
    announcement = await AnnouncementService(session).create(payload, current_user.user_id)
    return AnnouncementRead.model_validate(announcement)


@router.get("/announcements", response_model=list[AnnouncementRead])
async def list_announcements(
    target_type: str | None = Query(
        None, description="Filter by target type: ALL, FACULTY, DEPARTMENT, PROGRAM, COURSE"
    ),
    target_id: UUID | None = Query(None),
    published_only: bool = Query(False),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[AnnouncementRead]:
    announcements = await AnnouncementService(session).list(target_type, target_id, published_only)
    return [AnnouncementRead.model_validate(a) for a in announcements]


@router.get("/announcements/{announcement_id}", response_model=AnnouncementRead)
async def get_announcement(
    announcement_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> AnnouncementRead:
    announcement = await AnnouncementService(session).get(announcement_id)
    return AnnouncementRead.model_validate(announcement)


@router.patch("/announcements/{announcement_id}/publish", response_model=AnnouncementRead)
async def publish_announcement(
    announcement_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "STAFF")),
) -> AnnouncementRead:
    announcement = await AnnouncementService(session).publish(announcement_id)
    return AnnouncementRead.model_validate(announcement)


# ── Notifications (all authenticated users for own; ADMIN/STAFF to send) ──────


@router.get("/notifications", response_model=list[NotificationRead])
async def get_my_notifications(
    session: AsyncSession = Depends(db_session),
    current_user=Depends(get_current_user),
) -> list[NotificationRead]:
    notifications = await NotificationService(session).list_for_user(current_user.user_id)
    return [NotificationRead.model_validate(n) for n in notifications]


@router.patch("/notifications/{notification_id}/read", response_model=NotificationRead)
async def mark_notification_read(
    notification_id: UUID,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(get_current_user),
) -> NotificationRead:
    notif = await NotificationService(session).mark_read(notification_id, current_user.user_id)
    return NotificationRead.model_validate(notif)


@router.patch("/notifications/read-all", status_code=204)
async def mark_all_notifications_read(
    session: AsyncSession = Depends(db_session),
    current_user=Depends(get_current_user),
) -> None:
    await NotificationService(session).mark_all_read(current_user.user_id)


@router.post("/notifications/send", response_model=list[NotificationRead], status_code=201)
async def send_notifications(
    payload: SendNotificationRequest,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "STAFF")),
) -> list[NotificationRead]:
    notifications = await NotificationService(session).send(payload)
    return [NotificationRead.model_validate(n) for n in notifications]


@router.post("/notifications/broadcast", response_model=list[NotificationRead], status_code=201)
async def broadcast_notifications(
    payload: BroadcastRequest,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "STAFF")),
) -> list[NotificationRead]:
    notifications = await NotificationService(session).broadcast_to_roles(payload, session)
    return [NotificationRead.model_validate(n) for n in notifications]


# ── Email Logs (ADMIN / SUPER_ADMIN) ──────────────────────────────────────────


@router.get("/email-logs", response_model=list[EmailLogRead])
async def list_email_logs(
    limit: int = Query(100, le=500),
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> list[EmailLogRead]:
    logs = await EmailLogService(session).list(limit)
    return [EmailLogRead.model_validate(log) for log in logs]
