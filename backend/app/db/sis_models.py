from __future__ import annotations

import enum
from datetime import date, datetime, time
from decimal import Decimal
from uuid import UUID, uuid4

from sqlalchemy import (
    JSON,
    Boolean,
    CheckConstraint,
    Date,
    DateTime,
    Enum,
    ForeignKey,
    Index,
    Integer,
    Numeric,
    String,
    Text,
    Time,
    UniqueConstraint,
    func,
    text,
)
from app.db.types import GUID as PGUUID  # cross-dialect: PG UUID / SQLite CHAR(36)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class UserStatus(str, enum.Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    SUSPENDED = "SUSPENDED"
    PENDING = "PENDING"


class EnrollmentStatus(str, enum.Enum):
    ACTIVE = "ACTIVE"
    DROPPED = "DROPPED"
    COMPLETED = "COMPLETED"
    WITHDRAWN = "WITHDRAWN"


class AttendanceStatus(str, enum.Enum):
    PRESENT = "PRESENT"
    ABSENT = "ABSENT"
    LATE = "LATE"
    EXCUSED = "EXCUSED"


class FeeStatus(str, enum.Enum):
    PAID = "PAID"
    PARTIAL = "PARTIAL"
    OUTSTANDING = "OUTSTANDING"
    WAIVED = "WAIVED"


class PaymentMethod(str, enum.Enum):
    CASH = "CASH"
    BANK_TRANSFER = "BANK_TRANSFER"
    ONLINE = "ONLINE"
    CHEQUE = "CHEQUE"
    MOBILE_MONEY = "MOBILE_MONEY"


class AnnouncementTarget(str, enum.Enum):
    ALL = "ALL"
    FACULTY = "FACULTY"
    DEPARTMENT = "DEPARTMENT"
    PROGRAM = "PROGRAM"
    COURSE = "COURSE"


class NotificationType(str, enum.Enum):
    GRADE_POSTED = "GRADE_POSTED"
    ANNOUNCEMENT = "ANNOUNCEMENT"
    FEE_REMINDER = "FEE_REMINDER"
    REGISTRATION = "REGISTRATION"
    ATTENDANCE_ALERT = "ATTENDANCE_ALERT"
    SYSTEM = "SYSTEM"


class PriorityLevel(str, enum.Enum):
    LOW = "LOW"
    NORMAL = "NORMAL"
    HIGH = "HIGH"
    URGENT = "URGENT"


class AcademicStandingType(str, enum.Enum):
    GOOD_STANDING = "GOOD_STANDING"
    PROBATION = "PROBATION"
    SUSPENSION = "SUSPENSION"
    DEANS_LIST = "DEANS_LIST"


def _uuid_col() -> Mapped[UUID]:
    return mapped_column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)


class User(Base):
    __tablename__ = "users"
    __table_args__ = (
        # Postgres-only regex CHECK; skipped on SQLite (no `~*` operator).
        CheckConstraint(
            r"email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'",
            name="chk_users_email_format",
        ).ddl_if(dialect="postgresql"),
    )

    user_id: Mapped[UUID] = _uuid_col()
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    first_name: Mapped[str] = mapped_column(String(100), nullable=False)
    last_name: Mapped[str] = mapped_column(String(100), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(20))
    status: Mapped[UserStatus] = mapped_column(
        Enum(UserStatus, name="user_status"), default=UserStatus.PENDING, nullable=False
    )
    email_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Role(Base):
    __tablename__ = "roles"

    role_id: Mapped[UUID] = _uuid_col()
    role_name: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    role_code: Mapped[str] = mapped_column(String(30), unique=True, nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    is_system: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Permission(Base):
    __tablename__ = "permissions"

    permission_id: Mapped[UUID] = _uuid_col()
    permission_name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    permission_code: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    module: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    description: Mapped[str | None] = mapped_column(Text)


class UserRole(Base):
    __tablename__ = "user_roles"
    __table_args__ = (UniqueConstraint("user_id", "role_id", name="uq_user_roles"),)

    user_role_id: Mapped[UUID] = _uuid_col()
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    role_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("roles.role_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    assigned_by: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL")
    )
    assigned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class RolePermission(Base):
    __tablename__ = "role_permissions"
    __table_args__ = (UniqueConstraint("role_id", "permission_id", name="uq_role_permissions"),)

    rp_id: Mapped[UUID] = _uuid_col()
    role_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("roles.role_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    permission_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("permissions.permission_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    token_id: Mapped[UUID] = _uuid_col()
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    token_hash: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class ClientApp(Base):
    """Registered client applications — one per platform/product (web, mobile-student, etc.)."""

    __tablename__ = "client_apps"

    client_app_id: Mapped[UUID] = _uuid_col()
    client_id: Mapped[str] = mapped_column(String(64), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    platform: Mapped[str] = mapped_column(String(20), nullable=False)  # web | ios | android
    description: Mapped[str | None] = mapped_column(Text)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class UserSession(Base):
    __tablename__ = "user_sessions"

    session_id: Mapped[UUID] = _uuid_col()
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    token_jti: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    client_id: Mapped[str | None] = mapped_column(String(64), index=True)
    ip_address: Mapped[str | None] = mapped_column(String(45))
    user_agent: Mapped[str | None] = mapped_column(Text)
    device_info: Mapped[dict | None] = mapped_column(JSON)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class Faculty(Base):
    __tablename__ = "faculties"

    faculty_id: Mapped[UUID] = _uuid_col()
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    code: Mapped[str] = mapped_column(String(10), unique=True, nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    dean_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey(
            "lecturers.lecturer_id",
            ondelete="SET NULL",
            use_alter=True,
            name="fk_faculties_dean_id_lecturers",
        ),
    )
    status: Mapped[UserStatus] = mapped_column(
        Enum(UserStatus, name="user_status"), default=UserStatus.ACTIVE, nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Department(Base):
    __tablename__ = "departments"

    department_id: Mapped[UUID] = _uuid_col()
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    code: Mapped[str] = mapped_column(String(10), unique=True, nullable=False)
    faculty_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("faculties.faculty_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    hod_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey(
            "lecturers.lecturer_id",
            ondelete="SET NULL",
            use_alter=True,
            name="fk_departments_hod_id_lecturers",
        ),
    )
    description: Mapped[str | None] = mapped_column(Text)
    status: Mapped[UserStatus] = mapped_column(
        Enum(UserStatus, name="user_status"), default=UserStatus.ACTIVE, nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Program(Base):
    __tablename__ = "programs"
    __table_args__ = (
        CheckConstraint("duration_years BETWEEN 1 AND 7", name="chk_programs_duration"),
        CheckConstraint("total_credits > 0", name="chk_programs_credits"),
    )

    program_id: Mapped[UUID] = _uuid_col()
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    code: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    department_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("departments.department_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    duration_years: Mapped[int] = mapped_column(Integer, nullable=False)
    total_credits: Mapped[int] = mapped_column(Integer, default=120, nullable=False)
    award_type: Mapped[str] = mapped_column(String(50), default="BACHELOR", nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    status: Mapped[UserStatus] = mapped_column(
        Enum(UserStatus, name="user_status"), default=UserStatus.ACTIVE, nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Semester(Base):
    __tablename__ = "semesters"
    __table_args__ = (
        UniqueConstraint("academic_year", "semester_number", name="uq_semesters_name_year"),
        CheckConstraint("end_date > start_date", name="chk_semesters_dates"),
    )

    semester_id: Mapped[UUID] = _uuid_col()
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    academic_year: Mapped[str] = mapped_column(String(9), nullable=False, index=True)
    semester_number: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[date] = mapped_column(Date, nullable=False)
    registration_start: Mapped[date | None] = mapped_column(Date)
    registration_end: Mapped[date | None] = mapped_column(Date)
    exam_start_date: Mapped[date | None] = mapped_column(Date)
    exam_end_date: Mapped[date | None] = mapped_column(Date)
    is_active: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="UPCOMING", nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Student(Base):
    __tablename__ = "students"
    __table_args__ = (
        CheckConstraint("level IN (100, 200, 300, 400, 500, 600, 700)", name="chk_students_level"),
    )

    student_id: Mapped[UUID] = _uuid_col()
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    matric_no: Mapped[str] = mapped_column(String(20), unique=True, nullable=False, index=True)
    program_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("programs.program_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    level: Mapped[int] = mapped_column(Integer, default=100, nullable=False)
    session: Mapped[str] = mapped_column(String(9), nullable=False)
    enrollment_date: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False
    )
    status: Mapped[UserStatus] = mapped_column(
        Enum(UserStatus, name="user_status"), default=UserStatus.ACTIVE, nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Lecturer(Base):
    __tablename__ = "lecturers"

    lecturer_id: Mapped[UUID] = _uuid_col()
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    staff_id: Mapped[str] = mapped_column(String(20), unique=True, nullable=False, index=True)
    department_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("departments.department_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    title: Mapped[str | None] = mapped_column(String(20))
    employment_status: Mapped[str] = mapped_column(String(20), default="ACTIVE", nullable=False)
    hire_date: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False
    )
    specialization: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Applicant(Base):
    __tablename__ = "applicants"
    __table_args__ = (
        CheckConstraint(
            "application_status IN ('SUBMITTED','UNDER_REVIEW','INTERVIEW','ACCEPTED','REJECTED','WAITLISTED','CONVERTED')",
            name="chk_applicants_status",
        ),
    )

    applicant_id: Mapped[UUID] = _uuid_col()
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    application_no: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    program_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("programs.program_id", ondelete="RESTRICT"), nullable=False
    )
    application_status: Mapped[str] = mapped_column(
        String(20), default="SUBMITTED", nullable=False, index=True
    )
    submission_date: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False
    )
    decision_date: Mapped[date | None] = mapped_column(Date)
    decision_notes: Mapped[str | None] = mapped_column(Text)
    converted_student_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("students.student_id", ondelete="SET NULL")
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class ApplicantDocument(Base):
    __tablename__ = "applicant_documents"

    doc_id: Mapped[UUID] = _uuid_col()
    applicant_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("applicants.applicant_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    doc_type: Mapped[str] = mapped_column(String(50), nullable=False)
    file_path: Mapped[str] = mapped_column(String(500), nullable=False)
    file_name: Mapped[str | None] = mapped_column(String(255))
    file_size: Mapped[int | None] = mapped_column(Integer)
    mime_type: Mapped[str | None] = mapped_column(String(100))
    uploaded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Course(Base):
    __tablename__ = "courses"
    __table_args__ = (
        UniqueConstraint("code", "semester_id", name="uq_courses_code_semester"),
        CheckConstraint("credit_units > 0", name="chk_courses_credits"),
        CheckConstraint("max_capacity > 0", name="chk_courses_capacity"),
    )

    course_id: Mapped[UUID] = _uuid_col()
    code: Mapped[str] = mapped_column(String(20), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    credit_units: Mapped[int] = mapped_column(Integer, nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    program_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("programs.program_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    lecturer_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("lecturers.lecturer_id", ondelete="SET NULL"), index=True
    )
    semester_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("semesters.semester_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    max_capacity: Mapped[int] = mapped_column(Integer, default=50, nullable=False)
    current_enrollment: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    syllabus_path: Mapped[str | None] = mapped_column(String(500))
    status: Mapped[str] = mapped_column(String(20), default="ACTIVE", nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class CurriculumCourse(Base):
    __tablename__ = "curriculum_courses"
    __table_args__ = (
        UniqueConstraint("program_id", "course_id", name="uq_curriculum"),
        CheckConstraint("level IN (100, 200, 300, 400, 500, 600, 700)", name="chk_cc_level"),
        CheckConstraint("semester_offered IN (1,2)", name="chk_cc_semester"),
    )

    cc_id: Mapped[UUID] = _uuid_col()
    program_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("programs.program_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    course_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("courses.course_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    level: Mapped[int] = mapped_column(Integer, default=100, nullable=False)
    semester_offered: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    is_core: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_elective: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    min_credit_units: Mapped[int | None] = mapped_column(Integer)
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Prerequisite(Base):
    __tablename__ = "prerequisites"
    __table_args__ = (
        UniqueConstraint("course_id", "prereq_course_id", name="uq_prerequisites"),
        CheckConstraint("course_id != prereq_course_id", name="chk_prereq_not_self"),
    )

    prereq_id: Mapped[UUID] = _uuid_col()
    course_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("courses.course_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    prereq_course_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("courses.course_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    is_corequisite: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_strict: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class CourseMaterial(Base):
    __tablename__ = "course_materials"
    __table_args__ = (
        CheckConstraint(
            "material_type IN ('DOCUMENT','VIDEO','LINK','ASSIGNMENT','QUIZ','SYLLABUS')",
            name="chk_materials_type",
        ),
    )

    material_id: Mapped[UUID] = _uuid_col()
    course_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("courses.course_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    material_type: Mapped[str] = mapped_column(
        String(30), default="DOCUMENT", nullable=False, index=True
    )
    description: Mapped[str | None] = mapped_column(Text)
    file_path: Mapped[str | None] = mapped_column(String(500))
    external_url: Mapped[str | None] = mapped_column(String(500))
    uploaded_by: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="RESTRICT"), nullable=False
    )
    is_published: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    download_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Enrollment(Base):
    __tablename__ = "enrollments"
    __table_args__ = (
        UniqueConstraint("student_id", "course_id", name="uq_enrollments"),
        CheckConstraint("enrollment_date <= CURRENT_DATE", name="chk_enrollments_date"),
    )

    enrollment_id: Mapped[UUID] = _uuid_col()
    student_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("students.student_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    course_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("courses.course_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    enrollment_date: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False
    )
    status: Mapped[EnrollmentStatus] = mapped_column(
        Enum(EnrollmentStatus, name="enrollment_status"),
        default=EnrollmentStatus.ACTIVE,
        nullable=False,
        index=True,
    )
    enrolled_by: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL")
    )
    drop_date: Mapped[date | None] = mapped_column(Date)
    drop_reason: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class AttendanceSession(Base):
    __tablename__ = "attendance_sessions"

    attendance_session_id: Mapped[UUID] = _uuid_col()
    course_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("courses.course_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    session_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    topic: Mapped[str | None] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(Text)
    created_by: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="RESTRICT"), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class AttendanceRecord(Base):
    __tablename__ = "attendance_records"
    __table_args__ = (
        UniqueConstraint("attendance_session_id", "student_id", name="uq_attendance"),
    )

    record_id: Mapped[UUID] = _uuid_col()
    attendance_session_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("attendance_sessions.attendance_session_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    student_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("students.student_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    status: Mapped[AttendanceStatus] = mapped_column(
        Enum(AttendanceStatus, name="attendance_status"),
        default=AttendanceStatus.ABSENT,
        nullable=False,
        index=True,
    )
    recorded_by: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="RESTRICT"), nullable=False
    )
    notes: Mapped[str | None] = mapped_column(Text)
    recorded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class TimetableEntry(Base):
    __tablename__ = "timetable_entries"
    __table_args__ = (
        CheckConstraint(
            "day_of_week IN ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY')",
            name="chk_timetable_day",
        ),
        CheckConstraint("end_time > start_time", name="chk_timetable_time"),
        CheckConstraint(
            "entry_type IN ('LECTURE','LAB','TUTORIAL','SEMINAR','EXAM')", name="chk_timetable_type"
        ),
    )

    entry_id: Mapped[UUID] = _uuid_col()
    course_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("courses.course_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    day_of_week: Mapped[str] = mapped_column(String(10), nullable=False, index=True)
    start_time: Mapped[time] = mapped_column(Time, nullable=False)
    end_time: Mapped[time] = mapped_column(Time, nullable=False)
    venue: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    entry_type: Mapped[str] = mapped_column(String(20), default="LECTURE", nullable=False)
    recurrence: Mapped[str] = mapped_column(String(20), default="WEEKLY", nullable=False)
    effective_from: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False
    )
    effective_until: Mapped[date | None] = mapped_column(Date)
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class GradeAssessment(Base):
    __tablename__ = "grade_assessments"
    __table_args__ = (
        CheckConstraint("max_score > 0", name="chk_assessments_max"),
        CheckConstraint(
            "weight_percent > 0 AND weight_percent <= 100", name="chk_assessments_weight"
        ),
        CheckConstraint(
            "assessment_type IN ('CA_TEST','CA_ASSIGNMENT','CA_QUIZ','CA_PROJECT','EXAM','FINAL')",
            name="chk_assessments_type",
        ),
    )

    assessment_id: Mapped[UUID] = _uuid_col()
    course_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("courses.course_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    assessment_type: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    max_score: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)
    weight_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)
    due_date: Mapped[date | None] = mapped_column(Date)
    is_published: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_by: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="RESTRICT"), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Grade(Base):
    __tablename__ = "grades"
    __table_args__ = (
        UniqueConstraint("enrollment_id", "assessment_id", name="uq_grades"),
        CheckConstraint("score >= 0", name="chk_grades_score"),
    )

    grade_id: Mapped[UUID] = _uuid_col()
    enrollment_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("enrollments.enrollment_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    assessment_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("grade_assessments.assessment_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    score: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)
    percentage: Mapped[Decimal | None] = mapped_column(Numeric(5, 2))
    letter_grade: Mapped[str | None] = mapped_column(String(2))
    is_published: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False, index=True)
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    published_by: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL")
    )
    remarks: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class AcademicStanding(Base):
    __tablename__ = "academic_standings"
    __table_args__ = (
        UniqueConstraint("student_id", "semester_id", name="uq_standings"),
        CheckConstraint("gpa >= 0 AND gpa <= 5.00", name="chk_standings_gpa"),
        CheckConstraint("cgpa >= 0 AND cgpa <= 5.00", name="chk_standings_cgpa"),
    )

    standing_id: Mapped[UUID] = _uuid_col()
    student_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("students.student_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    semester_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("semesters.semester_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    gpa: Mapped[Decimal] = mapped_column(Numeric(3, 2), default=Decimal("0.00"), nullable=False)
    cgpa: Mapped[Decimal] = mapped_column(Numeric(3, 2), default=Decimal("0.00"), nullable=False)
    total_credits_attempted: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_credits_earned: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    standing: Mapped[AcademicStandingType] = mapped_column(
        Enum(AcademicStandingType, name="academic_standing_type"),
        default=AcademicStandingType.GOOD_STANDING,
        nullable=False,
        index=True,
    )
    standing_reason: Mapped[str | None] = mapped_column(Text)
    is_current: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class FeeStructure(Base):
    __tablename__ = "fee_structures"
    __table_args__ = (
        CheckConstraint("amount > 0", name="chk_fees_amount"),
        CheckConstraint(
            "fee_category IN ('TUITION','LAB','LIBRARY','REGISTRATION','EXAMINATION','ID_CARD','HOSTEL','OTHER')",
            name="chk_fees_category",
        ),
    )

    fee_structure_id: Mapped[UUID] = _uuid_col()
    fee_name: Mapped[str] = mapped_column(String(100), nullable=False)
    fee_code: Mapped[str] = mapped_column(String(30), unique=True, nullable=False)
    fee_category: Mapped[str] = mapped_column(
        String(50), default="TUITION", nullable=False, index=True
    )
    description: Mapped[str | None] = mapped_column(Text)
    amount: Mapped[Decimal] = mapped_column(Numeric(18, 2), nullable=False)
    currency: Mapped[str] = mapped_column(String(3), default="USD", nullable=False)
    applies_to: Mapped[str] = mapped_column(String(20), default="ALL", nullable=False)
    program_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("programs.program_id", ondelete="SET NULL"), index=True
    )
    faculty_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("faculties.faculty_id", ondelete="SET NULL")
    )
    level: Mapped[int | None] = mapped_column(Integer)
    effective_from: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False
    )
    effective_until: Mapped[date | None] = mapped_column(Date)
    is_mandatory: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False, index=True)
    created_by: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL")
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class FeeCharge(Base):
    __tablename__ = "fee_charges"
    __table_args__ = (
        CheckConstraint("amount > 0", name="chk_charges_amount"),
        CheckConstraint("amount_paid >= 0", name="chk_charges_paid_low"),
        Index("idx_charges_student_semester", "student_id", "semester_id"),
    )

    charge_id: Mapped[UUID] = _uuid_col()
    student_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("students.student_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    semester_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("semesters.semester_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    fee_structure_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("fee_structures.fee_structure_id", ondelete="RESTRICT"),
        nullable=False,
    )
    amount: Mapped[Decimal] = mapped_column(Numeric(18, 2), nullable=False)
    amount_paid: Mapped[Decimal] = mapped_column(
        Numeric(18, 2), default=Decimal("0.00"), nullable=False
    )
    discount_amount: Mapped[Decimal] = mapped_column(
        Numeric(18, 2), default=Decimal("0.00"), nullable=False
    )
    due_date: Mapped[date | None] = mapped_column(Date)
    description: Mapped[str | None] = mapped_column(Text)
    status: Mapped[FeeStatus] = mapped_column(
        Enum(FeeStatus, name="fee_status"),
        default=FeeStatus.OUTSTANDING,
        nullable=False,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Payment(Base):
    __tablename__ = "payments"
    __table_args__ = (CheckConstraint("amount > 0", name="chk_payments_amount"),)

    payment_id: Mapped[UUID] = _uuid_col()
    student_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("students.student_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    charge_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("fee_charges.charge_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    amount: Mapped[Decimal] = mapped_column(Numeric(18, 2), nullable=False)
    payment_method: Mapped[PaymentMethod] = mapped_column(
        Enum(PaymentMethod, name="payment_method"), nullable=False, index=True
    )
    transaction_ref: Mapped[str | None] = mapped_column(String(100))
    payment_date: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False, index=True
    )
    receipt_number: Mapped[str | None] = mapped_column(String(50), unique=True)
    notes: Mapped[str | None] = mapped_column(Text)
    recorded_by: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="RESTRICT"), nullable=False
    )
    is_reversed: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    reversed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    reversal_reason: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Scholarship(Base):
    __tablename__ = "scholarships"
    __table_args__ = (
        CheckConstraint(
            "scholarship_type IN ('MERIT','NEED_BASED','SPORTS','RESEARCH','GOVERNMENT','PRIVATE','OTHER')",
            name="chk_scholarships_type",
        ),
    )

    scholarship_id: Mapped[UUID] = _uuid_col()
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    scholarship_type: Mapped[str] = mapped_column(
        String(50), default="MERIT", nullable=False, index=True
    )
    description: Mapped[str | None] = mapped_column(Text)
    amount: Mapped[Decimal | None] = mapped_column(Numeric(18, 2))
    percentage_coverage: Mapped[Decimal | None] = mapped_column(Numeric(5, 2))
    eligibility_criteria: Mapped[str | None] = mapped_column(Text)
    max_recipients: Mapped[int | None] = mapped_column(Integer)
    application_deadline: Mapped[date | None] = mapped_column(Date)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False, index=True)
    created_by: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL")
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class ScholarshipAward(Base):
    __tablename__ = "scholarship_awards"
    __table_args__ = (
        UniqueConstraint("scholarship_id", "student_id", "semester_id", name="uq_awards"),
        CheckConstraint("amount > 0 OR percentage_coverage > 0", name="chk_awards_amount"),
    )

    award_id: Mapped[UUID] = _uuid_col()
    scholarship_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("scholarships.scholarship_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    student_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("students.student_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    semester_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("semesters.semester_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    amount: Mapped[Decimal] = mapped_column(Numeric(18, 2), default=Decimal("0.00"), nullable=False)
    percentage_coverage: Mapped[Decimal | None] = mapped_column(Numeric(5, 2))
    award_date: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False
    )
    effective_from: Mapped[date] = mapped_column(
        Date, server_default=text("CURRENT_DATE"), nullable=False
    )
    effective_until: Mapped[date | None] = mapped_column(Date)
    status: Mapped[str] = mapped_column(String(20), default="ACTIVE", nullable=False)
    approved_by: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL")
    )
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Announcement(Base):
    __tablename__ = "announcements"

    announcement_id: Mapped[UUID] = _uuid_col()
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    author_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.user_id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    target_type: Mapped[AnnouncementTarget] = mapped_column(
        Enum(AnnouncementTarget, name="announcement_target"),
        default=AnnouncementTarget.ALL,
        nullable=False,
    )
    target_id: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True))
    priority: Mapped[PriorityLevel] = mapped_column(
        Enum(PriorityLevel, name="priority_level"),
        default=PriorityLevel.NORMAL,
        nullable=False,
        index=True,
    )
    is_pinned: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_urgent: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    attachment_path: Mapped[str | None] = mapped_column(String(500))
    view_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Notification(Base):
    __tablename__ = "notifications"

    notification_id: Mapped[UUID] = _uuid_col()
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    notification_type: Mapped[NotificationType] = mapped_column(
        Enum(NotificationType, name="notification_type"),
        default=NotificationType.SYSTEM,
        nullable=False,
        index=True,
    )
    reference_type: Mapped[str | None] = mapped_column(String(50))
    reference_id: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True))
    action_url: Mapped[str | None] = mapped_column(String(500))
    is_read: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class EmailLog(Base):
    __tablename__ = "email_logs"

    email_id: Mapped[UUID] = _uuid_col()
    recipient_email: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    user_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL"), index=True
    )
    subject: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str | None] = mapped_column(Text)
    template: Mapped[str | None] = mapped_column(String(50))
    template_data: Mapped[dict | None] = mapped_column(JSON)
    status: Mapped[str] = mapped_column(String(20), default="PENDING", nullable=False, index=True)
    error_message: Mapped[str | None] = mapped_column(Text)
    sent_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), index=True)
    delivered_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    opened_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    ip_address: Mapped[str | None] = mapped_column(String(45))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class AuditLog(Base):
    __tablename__ = "audit_logs"
    __table_args__ = (Index("idx_audit_entity_time", "entity_type", "created_at"),)

    audit_id: Mapped[UUID] = _uuid_col()
    user_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL"), index=True
    )
    action: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    entity_type: Mapped[str] = mapped_column(String(50), nullable=False)
    entity_id: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True))
    old_values: Mapped[dict | None] = mapped_column(JSON)
    new_values: Mapped[dict | None] = mapped_column(JSON)
    changes_summary: Mapped[str | None] = mapped_column(Text)
    ip_address: Mapped[str | None] = mapped_column(String(45))
    user_agent: Mapped[str | None] = mapped_column(Text)
    session_ref: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class SystemConfig(Base):
    __tablename__ = "system_configs"
    __table_args__ = (
        CheckConstraint(
            "data_type IN ('STRING','INTEGER','DECIMAL','BOOLEAN','JSON','DATE')",
            name="chk_config_type",
        ),
    )

    config_id: Mapped[UUID] = _uuid_col()
    config_key: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    config_value: Mapped[str] = mapped_column(Text, nullable=False)
    data_type: Mapped[str] = mapped_column(String(20), default="STRING", nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    category: Mapped[str] = mapped_column(String(50), default="GENERAL", nullable=False, index=True)
    is_editable: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_sensitive: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    updated_by: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("users.user_id", ondelete="SET NULL")
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
