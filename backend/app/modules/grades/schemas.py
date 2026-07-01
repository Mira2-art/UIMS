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


class GradeBulkSubmit(BaseModel):
    """Many grades at once — exam-marks Excel upload / CA score grids."""

    items: list[GradeSubmit]


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


class CourseResultRead(BaseModel):
    """Combined CA (/30) + EXAM (/70) result — the final course grade."""

    enrollment_id: UUID
    ca_score: Decimal
    exam_score: Decimal
    total_score: Decimal
    letter_grade: str
    grade_point: Decimal


class TranscriptCourseView(BaseModel):
    """A student's view of one enrolled course — published components only."""

    course_id: UUID
    code: str
    title: str
    credit_units: int
    ca_score: Decimal | None  # /30, null until CA is published
    exam_score: Decimal | None  # /70, null until EXAM is published
    total: Decimal | None  # /100, only once finalized
    letter_grade: str | None
    finalized: bool


class TranscriptSemesterView(BaseModel):
    semester_id: UUID
    name: str
    semester_number: int
    academic_year: str
    gpa: Decimal | None  # shown once the semester's results are published
    courses: list[TranscriptCourseView]


class TranscriptView(BaseModel):
    cgpa: Decimal | None
    semesters: list[TranscriptSemesterView]


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
