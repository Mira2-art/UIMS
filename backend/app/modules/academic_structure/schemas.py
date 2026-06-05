from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class FacultyCreate(BaseModel):
    name: str
    code: str
    description: str | None = None
    dean_id: UUID | None = None


class FacultyUpdate(BaseModel):
    name: str | None = None
    code: str | None = None
    description: str | None = None
    dean_id: UUID | None = None
    status: str | None = None


class FacultyRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    faculty_id: UUID
    name: str
    code: str
    description: str | None
    dean_id: UUID | None
    status: str
    created_at: datetime
    updated_at: datetime


class DepartmentCreate(BaseModel):
    name: str
    code: str
    faculty_id: UUID
    hod_id: UUID | None = None
    description: str | None = None


class DepartmentUpdate(BaseModel):
    name: str | None = None
    code: str | None = None
    faculty_id: UUID | None = None
    hod_id: UUID | None = None
    description: str | None = None
    status: str | None = None


class DepartmentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    department_id: UUID
    name: str
    code: str
    faculty_id: UUID
    hod_id: UUID | None
    description: str | None
    status: str
    created_at: datetime
    updated_at: datetime


class ProgramCreate(BaseModel):
    name: str
    code: str
    department_id: UUID
    duration_years: int
    total_credits: int = 120
    award_type: str = "BACHELOR"
    description: str | None = None


class ProgramUpdate(BaseModel):
    name: str | None = None
    code: str | None = None
    department_id: UUID | None = None
    duration_years: int | None = None
    total_credits: int | None = None
    award_type: str | None = None
    description: str | None = None
    status: str | None = None


class ProgramRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    program_id: UUID
    name: str
    code: str
    department_id: UUID
    duration_years: int
    total_credits: int
    award_type: str
    description: str | None
    status: str
    created_at: datetime
    updated_at: datetime


class SemesterCreate(BaseModel):
    name: str
    academic_year: str
    semester_number: int = 1
    start_date: date
    end_date: date
    registration_start: date | None = None
    registration_end: date | None = None
    exam_start_date: date | None = None
    exam_end_date: date | None = None


class SemesterUpdate(BaseModel):
    name: str | None = None
    start_date: date | None = None
    end_date: date | None = None
    registration_start: date | None = None
    registration_end: date | None = None
    exam_start_date: date | None = None
    exam_end_date: date | None = None
    status: str | None = None


class SemesterRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    semester_id: UUID
    name: str
    academic_year: str
    semester_number: int
    start_date: date
    end_date: date
    registration_start: date | None
    registration_end: date | None
    exam_start_date: date | None
    exam_end_date: date | None
    is_active: bool
    status: str
    created_at: datetime
    updated_at: datetime


class CurriculumCourseCreate(BaseModel):
    course_id: UUID
    level: int = 100
    semester_offered: int = 1
    is_core: bool = True
    is_elective: bool = False
    min_credit_units: int | None = None
    notes: str | None = None


class CurriculumCourseRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    cc_id: UUID
    program_id: UUID
    course_id: UUID
    level: int
    semester_offered: int
    is_core: bool
    is_elective: bool
    min_credit_units: int | None
    notes: str | None
    created_at: datetime
