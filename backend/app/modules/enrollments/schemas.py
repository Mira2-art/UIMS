from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class EnrollmentCreate(BaseModel):
    student_id: UUID
    course_id: UUID
    enrolled_by: UUID | None = None


class DropEnrollmentRequest(BaseModel):
    drop_reason: str | None = None


class WithdrawRequest(BaseModel):
    reason: str | None = None


class EnrollmentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    enrollment_id: UUID
    student_id: UUID
    course_id: UUID
    enrollment_date: date
    status: str
    enrolled_by: UUID | None
    drop_date: date | None
    drop_reason: str | None
    created_at: datetime
    updated_at: datetime
