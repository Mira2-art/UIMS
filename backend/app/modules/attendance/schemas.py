from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class AttendanceSessionCreate(BaseModel):
    course_id: UUID
    session_date: date
    topic: str | None = None
    description: str | None = None


class AttendanceSessionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    attendance_session_id: UUID
    course_id: UUID
    session_date: date
    topic: str | None
    description: str | None
    created_by: UUID
    created_at: datetime


class AttendanceRecordItem(BaseModel):
    student_id: UUID
    status: str
    notes: str | None = None


class BulkAttendanceRequest(BaseModel):
    records: list[AttendanceRecordItem]


class AttendanceRecordRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    record_id: UUID
    attendance_session_id: UUID
    student_id: UUID
    status: str
    recorded_by: UUID
    notes: str | None
    recorded_at: datetime


class StudentAttendanceSummary(BaseModel):
    student_id: UUID
    course_id: UUID
    total_sessions: int
    present: int
    absent: int
    late: int
    excused: int
    attendance_rate: float
