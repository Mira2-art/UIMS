from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class LecturerCreate(BaseModel):
    user_id: UUID
    staff_id: str
    department_id: UUID
    title: str | None = None
    employment_status: str = "ACTIVE"
    specialization: str | None = None


class LecturerUpdate(BaseModel):
    department_id: UUID | None = None
    title: str | None = None
    employment_status: str | None = None
    specialization: str | None = None


class LecturerRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    lecturer_id: UUID
    user_id: UUID
    staff_id: str
    department_id: UUID
    title: str | None
    employment_status: str
    hire_date: date
    specialization: str | None
    created_at: datetime
    updated_at: datetime
