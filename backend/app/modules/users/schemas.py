from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class UserUpdate(BaseModel):
    first_name: str | None = None
    last_name: str | None = None
    phone: str | None = None


class StatusUpdate(BaseModel):
    status: str


class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id: UUID
    email: str
    first_name: str
    last_name: str
    phone: str | None
    status: str
    email_verified: bool
    last_login_at: datetime | None
    created_at: datetime
    updated_at: datetime
