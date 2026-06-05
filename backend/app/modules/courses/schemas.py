from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class CourseCreate(BaseModel):
    code: str
    title: str
    credit_units: int
    program_id: UUID
    semester_id: UUID
    lecturer_id: UUID | None = None
    max_capacity: int = 50
    description: str | None = None


class CourseUpdate(BaseModel):
    title: str | None = None
    credit_units: int | None = None
    lecturer_id: UUID | None = None
    max_capacity: int | None = None
    description: str | None = None
    status: str | None = None


class AssignLecturerRequest(BaseModel):
    lecturer_id: UUID | None = None


class CourseRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    course_id: UUID
    code: str
    title: str
    credit_units: int
    description: str | None
    program_id: UUID
    lecturer_id: UUID | None
    semester_id: UUID
    max_capacity: int
    current_enrollment: int
    syllabus_path: str | None
    status: str
    created_at: datetime
    updated_at: datetime


class PrerequisiteCreate(BaseModel):
    prereq_course_id: UUID
    is_corequisite: bool = False
    is_strict: bool = True
    notes: str | None = None


class PrerequisiteRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    prereq_id: UUID
    course_id: UUID
    prereq_course_id: UUID
    is_corequisite: bool
    is_strict: bool
    notes: str | None
    created_at: datetime


class CourseMaterialCreate(BaseModel):
    title: str
    material_type: str = "DOCUMENT"
    description: str | None = None
    file_path: str | None = None
    external_url: str | None = None
    is_published: bool = True


class CourseMaterialRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    material_id: UUID
    course_id: UUID
    title: str
    material_type: str
    description: str | None
    file_path: str | None
    external_url: str | None
    uploaded_by: UUID
    is_published: bool
    download_count: int
    created_at: datetime
    updated_at: datetime


class TimetableEntryCreate(BaseModel):
    day_of_week: str
    start_time: str
    end_time: str
    venue: str
    entry_type: str = "LECTURE"
    recurrence: str = "WEEKLY"


class TimetableEntryRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    entry_id: UUID
    course_id: UUID
    day_of_week: str
    start_time: str
    end_time: str
    venue: str
    entry_type: str
    recurrence: str
    created_at: datetime
    updated_at: datetime
