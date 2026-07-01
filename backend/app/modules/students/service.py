from __future__ import annotations

from datetime import date
from uuid import UUID

from fastapi import HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.storage import normalize_doc_type, save_upload_file
from app.db.sis_models import Applicant, ApplicantDocument, Student, UserStatus
from app.modules.students.repository import (
    ApplicantDocumentRepository,
    ApplicantRepository,
    StudentRepository,
)
from app.modules.students.schemas import (
    ApplicantConvert,
    ApplicantCreate,
    ApplicantDocumentCreate,
    ApplicantStatusUpdate,
    StudentCreate,
    StudentSummaryRead,
    StudentUpdate,
)


class StudentService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = StudentRepository(session)

    async def create(self, payload: StudentCreate) -> Student:
        if await self.repo.get_by_matric_no(payload.matric_no):
            raise HTTPException(
                status.HTTP_409_CONFLICT, f"Matric number '{payload.matric_no}' already exists"
            )
        if await self.repo.get_by_user_id(payload.user_id):
            raise HTTPException(status.HTTP_409_CONFLICT, "User is already registered as a student")
        student = Student(
            user_id=payload.user_id,
            matric_no=payload.matric_no,
            program_id=payload.program_id,
            level=payload.level,
            session=payload.session,
            status=UserStatus.ACTIVE,
        )
        return await self.repo.create(student)

    async def list(
        self,
        program_id: UUID | None = None,
        level: int | None = None,
        student_status: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Student]:
        return await self.repo.list_filtered(program_id, level, student_status, limit, offset)

    async def get(self, student_id: UUID) -> Student:
        return await self.repo.get_or_404(student_id)

    async def get_for_user(self, user_id: UUID) -> Student:
        """Resolve the Student record for the authenticated user (for `/students/me`)."""
        student = await self.repo.get_by_user_id(user_id)
        if student is None:
            raise HTTPException(
                status.HTTP_404_NOT_FOUND, "No student profile for this user"
            )
        return student

    async def update(self, student_id: UUID, payload: StudentUpdate) -> Student:
        student = await self.repo.get_or_404(student_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(student, field, value)
        return await self.repo.update(student)

    async def delete(self, student_id: UUID) -> None:
        student = await self.repo.get_or_404(student_id)
        student.status = UserStatus.INACTIVE
        await self.repo.update(student)

    async def get_summary(self, student_id: UUID) -> StudentSummaryRead:
        student = await self.repo.get_or_404(student_id)
        enrollment_count = await self.repo.count_enrollments(student_id)
        return StudentSummaryRead(
            student_id=student.student_id,
            matric_no=student.matric_no,
            level=student.level,
            status=str(student.status),
            enrollment_count=enrollment_count,
        )

    async def get_transcript(self, student_id: UUID) -> list:
        await self.repo.get_or_404(student_id)
        from app.modules.grades.repository import GradeRepository

        repo = GradeRepository(self.repo.session)
        grades = await repo.list_for_student(student_id)
        return [g for g in grades if g.is_published]

    async def get_standing(self, student_id: UUID):
        await self.repo.get_or_404(student_id)
        from app.modules.grades.repository import AcademicStandingRepository

        repo = AcademicStandingRepository(self.repo.session)
        return await repo.get_current_for_student(student_id)

    async def get_timetable(self, student_id: UUID) -> list:
        from sqlalchemy import select

        from app.db.sis_models import Course, Enrollment, EnrollmentStatus, TimetableEntry

        result = await self.repo.session.execute(
            select(TimetableEntry)
            .join(Course, Course.course_id == TimetableEntry.course_id)
            .join(Enrollment, Enrollment.course_id == Course.course_id)
            .where(
                Enrollment.student_id == student_id,
                Enrollment.status == EnrollmentStatus.ACTIVE,
            )
        )
        return list(result.scalars().all())

    async def get_charges(self, student_id: UUID) -> list:
        await self.repo.get_or_404(student_id)
        from app.modules.finance.repository import FeeChargeRepository

        repo = FeeChargeRepository(self.repo.session)
        return await repo.list_by_student(student_id)

    async def get_scholarships(self, student_id: UUID) -> list:
        await self.repo.get_or_404(student_id)
        from app.modules.finance.repository import ScholarshipAwardRepository

        repo = ScholarshipAwardRepository(self.repo.session)
        return await repo.list_by_student(student_id)

    async def get_payments(self, student_id: UUID) -> list:
        await self.repo.get_or_404(student_id)
        from app.modules.finance.repository import PaymentRepository

        repo = PaymentRepository(self.repo.session)
        return await repo.list_by_student(student_id)

    async def get_attendance(self, student_id: UUID, course_id: UUID | None = None) -> list:
        from sqlalchemy import select

        from app.db.sis_models import AttendanceRecord, AttendanceSession

        await self.repo.get_or_404(student_id)
        query = select(AttendanceRecord).where(AttendanceRecord.student_id == student_id)
        if course_id:
            query = query.join(
                AttendanceSession,
                AttendanceSession.attendance_session_id == AttendanceRecord.attendance_session_id,
            ).where(AttendanceSession.course_id == course_id)
        result = await self.repo.session.execute(query)
        return list(result.scalars().all())


class ApplicantService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = ApplicantRepository(session)
        self.student_repo = StudentRepository(session)
        self.doc_repo = ApplicantDocumentRepository(session)

    async def create(self, payload: ApplicantCreate) -> Applicant:
        if await self.repo.get_by_application_no(payload.application_no):
            raise HTTPException(
                status.HTTP_409_CONFLICT,
                f"Application number '{payload.application_no}' already exists",
            )
        applicant = Applicant(
            user_id=payload.user_id,
            application_no=payload.application_no,
            program_id=payload.program_id,
            application_status="SUBMITTED",
        )
        return await self.repo.create(applicant)

    async def list(
        self,
        application_status: str | None = None,
        program_id: UUID | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Applicant]:
        return await self.repo.list_filtered(application_status, program_id, limit, offset)

    async def get(self, applicant_id: UUID) -> Applicant:
        return await self.repo.get_or_404(applicant_id)

    async def update_status(self, applicant_id: UUID, payload: ApplicantStatusUpdate) -> Applicant:
        applicant = await self.repo.get_or_404(applicant_id)
        applicant.application_status = payload.application_status
        if payload.decision_notes:
            applicant.decision_notes = payload.decision_notes
        applicant.decision_date = date.today()
        return await self.repo.update(applicant)

    async def convert(self, applicant_id: UUID, payload: ApplicantConvert) -> Student:
        applicant = await self.repo.get_or_404(applicant_id)
        if applicant.application_status != "ACCEPTED":
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "Only ACCEPTED applicants can be converted to students"
            )
        if await self.student_repo.get_by_matric_no(payload.matric_no):
            raise HTTPException(
                status.HTTP_409_CONFLICT, f"Matric number '{payload.matric_no}' already exists"
            )
        student = Student(
            user_id=applicant.user_id,
            matric_no=payload.matric_no,
            program_id=payload.program_id,
            level=payload.level,
            session=payload.session,
            status=UserStatus.ACTIVE,
        )
        student = await self.student_repo.create(student)
        applicant.converted_student_id = student.student_id
        applicant.application_status = "CONVERTED"
        await self.repo.update(applicant)
        return student

    async def add_document(
        self, applicant_id: UUID, payload: ApplicantDocumentCreate
    ) -> ApplicantDocument:
        await self.repo.get_or_404(applicant_id)
        doc = ApplicantDocument(
            applicant_id=applicant_id,
            doc_type=payload.doc_type,
            file_path=payload.file_path,
            file_name=payload.file_name,
            file_size=payload.file_size,
            mime_type=payload.mime_type,
        )
        return await self.doc_repo.create(doc)

    async def upload_document(
        self, applicant_id: UUID, doc_type: str, upload: UploadFile
    ) -> ApplicantDocument:
        await self.repo.get_or_404(applicant_id)
        normalized_doc_type = normalize_doc_type(doc_type)
        stored = await save_upload_file(
            upload,
            folder_parts=("applicants", str(applicant_id)),
            doc_type=normalized_doc_type,
        )
        doc = ApplicantDocument(
            applicant_id=applicant_id,
            doc_type=normalized_doc_type,
            file_path=stored.file_path,
            file_name=stored.file_name,
            file_size=stored.file_size,
            mime_type=stored.mime_type,
        )
        return await self.doc_repo.create(doc)

    async def list_documents(self, applicant_id: UUID) -> list[ApplicantDocument]:
        await self.repo.get_or_404(applicant_id)
        return await self.doc_repo.list_by_applicant(applicant_id)

    async def delete_document(self, doc_id: UUID) -> None:
        doc = await self.doc_repo.get_or_404(doc_id)
        await self.doc_repo.delete(doc)
