from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class AnnouncementCreate(BaseModel):
    title: str
    content: str
    target_type: str = "ALL"
    target_id: UUID | None = None
    priority: str = "NORMAL"
    is_pinned: bool = False
    is_urgent: bool = False
    expires_at: datetime | None = None


class AnnouncementRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    announcement_id: UUID
    title: str
    content: str
    author_id: UUID
    target_type: str
    target_id: UUID | None
    priority: str
    is_pinned: bool
    is_urgent: bool
    view_count: int
    expires_at: datetime | None
    published_at: datetime | None
    created_at: datetime
    updated_at: datetime


class SendNotificationRequest(BaseModel):
    user_ids: list[UUID]
    title: str
    message: str
    notification_type: str = "SYSTEM"
    reference_type: str | None = None
    reference_id: UUID | None = None
    action_url: str | None = None


class BroadcastRequest(BaseModel):
    role_codes: list[str]
    title: str
    message: str
    notification_type: str = "ANNOUNCEMENT"
    action_url: str | None = None


class NotificationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    notification_id: UUID
    user_id: UUID
    title: str
    message: str
    notification_type: str
    reference_type: str | None
    reference_id: UUID | None
    action_url: str | None
    is_read: bool
    read_at: datetime | None
    created_at: datetime


class EmailLogRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    email_id: UUID
    recipient_email: str
    user_id: UUID | None
    subject: str
    template: str | None
    status: str
    sent_at: datetime | None
    created_at: datetime
