from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class StudentCreate(BaseModel):
    user_id: UUID
    matric_no: str
    program_id: UUID
    level: int = 100
    session: str


class StudentUpdate(BaseModel):
    program_id: UUID | None = None
    level: int | None = None
    session: str | None = None
    status: str | None = None


class StudentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    student_id: UUID
    user_id: UUID
    matric_no: str
    program_id: UUID
    level: int
    session: str
    enrollment_date: date
    status: str
    created_at: datetime
    updated_at: datetime


class StudentSummaryRead(BaseModel):
    student_id: UUID
    matric_no: str
    level: int
    status: str
    enrollment_count: int = 0


class ApplicantCreate(BaseModel):
    user_id: UUID
    application_no: str
    program_id: UUID


class ApplicantStatusUpdate(BaseModel):
    application_status: str
    decision_notes: str | None = None


class ApplicantConvert(BaseModel):
    matric_no: str
    program_id: UUID
    level: int = 100
    session: str


class ApplicantRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    applicant_id: UUID
    user_id: UUID
    application_no: str
    program_id: UUID
    application_status: str
    submission_date: date
    decision_date: date | None
    decision_notes: str | None
    converted_student_id: UUID | None
    created_at: datetime
    updated_at: datetime


class ApplicantDocumentCreate(BaseModel):
    doc_type: str
    file_path: str
    file_name: str | None = None
    file_size: int | None = None
    mime_type: str | None = None


class ApplicantDocumentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    doc_id: UUID
    applicant_id: UUID
    doc_type: str
    file_path: str
    file_name: str | None
    file_size: int | None
    mime_type: str | None
    uploaded_at: datetime
