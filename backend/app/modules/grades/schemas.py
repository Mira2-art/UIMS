from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class AssessmentCreate(BaseModel):
    course_id: UUID
    assessment_type: str
    name: str
    max_score: Decimal
    weight_percent: Decimal
    description: str | None = None
    due_date: date | None = None


class AssessmentUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    max_score: Decimal | None = None
    weight_percent: Decimal | None = None
    due_date: date | None = None
    is_published: bool | None = None


class AssessmentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    assessment_id: UUID
    course_id: UUID
    assessment_type: str
    name: str
    description: str | None
    max_score: Decimal
    weight_percent: Decimal
    due_date: date | None
    is_published: bool
    created_by: UUID
    created_at: datetime
    updated_at: datetime


class GradeSubmit(BaseModel):
    enrollment_id: UUID
    assessment_id: UUID
    score: Decimal
    remarks: str | None = None


class GradeRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    grade_id: UUID
    enrollment_id: UUID
    assessment_id: UUID
    score: Decimal
    percentage: Decimal | None
    letter_grade: str | None
    is_published: bool
    published_at: datetime | None
    published_by: UUID | None
    remarks: str | None
    created_at: datetime
    updated_at: datetime


class AcademicStandingCreate(BaseModel):
    student_id: UUID
    semester_id: UUID


class AcademicStandingRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    standing_id: UUID
    student_id: UUID
    semester_id: UUID
    gpa: Decimal
    cgpa: Decimal
    total_credits_attempted: int
    total_credits_earned: int
    standing: str
    standing_reason: str | None
    is_current: bool
    created_at: datetime
    updated_at: datetime
