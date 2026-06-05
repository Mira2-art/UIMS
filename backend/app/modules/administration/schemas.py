from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class SystemConfigUpdate(BaseModel):
    config_value: str


class SystemConfigRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    config_id: UUID
    config_key: str
    config_value: str
    data_type: str
    description: str | None
    category: str
    is_editable: bool
    is_sensitive: bool
    updated_at: datetime
    created_at: datetime


class AuditLogRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    audit_id: UUID
    user_id: UUID | None
    action: str
    entity_type: str
    entity_id: UUID | None
    changes_summary: str | None
    ip_address: str | None
    created_at: datetime


class UserReportRead(BaseModel):
    status: str
    count: int


class EnrollmentReportRead(BaseModel):
    semester_id: UUID
    total_enrollments: int
    active: int
    dropped: int
