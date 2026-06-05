from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, own_student_or_roles, require_roles
from app.modules.attendance.schemas import AttendanceRecordRead
from app.modules.courses.schemas import TimetableEntryRead
from app.modules.finance.schemas import FeeChargeRead, PaymentRead, ScholarshipAwardRead
from app.modules.grades.schemas import AcademicStandingRead, GradeRead
from app.modules.students.schemas import (
    ApplicantConvert,
    ApplicantCreate,
    ApplicantDocumentCreate,
    ApplicantDocumentRead,
    ApplicantRead,
    ApplicantStatusUpdate,
    StudentCreate,
    StudentRead,
    StudentSummaryRead,
    StudentUpdate,
)
from app.modules.students.service import ApplicantService, StudentService

router = APIRouter()

# ── Students (ADMIN / SUPER_ADMIN / REGISTRAR manage; STUDENT views own) ──────


@router.post("", response_model=StudentRead, status_code=201)
async def create_student(
    payload: StudentCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> StudentRead:
    student = await StudentService(session).create(payload)
    return StudentRead.model_validate(student)


@router.get("", response_model=list[StudentRead])
async def list_students(
    program_id: UUID | None = Query(None),
    level: int | None = Query(None),
    status: str | None = Query(None),
    limit: int = Query(100, le=500),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "LECTURER", "FINANCE")),
) -> list[StudentRead]:
    students = await StudentService(session).list(program_id, level, status, limit, offset)
    return [StudentRead.model_validate(s) for s in students]


@router.get("/{student_id}", response_model=StudentRead)
async def get_student(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "LECTURER")),
) -> StudentRead:
    student = await StudentService(session).get(student_id)
    return StudentRead.model_validate(student)


@router.put("/{student_id}", response_model=StudentRead)
async def update_student(
    student_id: UUID,
    payload: StudentUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> StudentRead:
    student = await StudentService(session).update(student_id, payload)
    return StudentRead.model_validate(student)


@router.delete("/{student_id}", status_code=204)
async def deactivate_student(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> None:
    await StudentService(session).delete(student_id)


@router.get("/{student_id}/summary", response_model=StudentSummaryRead)
async def get_student_summary(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> StudentSummaryRead:
    return await StudentService(session).get_summary(student_id)


# ── Transcript (published grades — STUDENT views own, staff views any) ─────────


@router.get("/{student_id}/transcript", response_model=list[GradeRead])
async def get_transcript(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "LECTURER")),
) -> list[GradeRead]:
    grades = await StudentService(session).get_transcript(student_id)
    return [GradeRead.model_validate(g) for g in grades]


# ── Academic standing (STUDENT views own, staff views any) ────────────────────


@router.get("/{student_id}/standing", response_model=AcademicStandingRead | None)
async def get_standing(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> AcademicStandingRead | None:
    standing = await StudentService(session).get_standing(student_id)
    return AcademicStandingRead.model_validate(standing) if standing else None


# ── Timetable (STUDENT views own, staff views any) ────────────────────────────


@router.get("/{student_id}/timetable", response_model=list[TimetableEntryRead])
async def get_student_timetable(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> list[TimetableEntryRead]:
    entries = await StudentService(session).get_timetable(student_id)
    return [TimetableEntryRead.model_validate(e) for e in entries]


# ── Finance sub-resources (STUDENT views own, FINANCE/ADMIN views any) ────────


@router.get("/{student_id}/charges", response_model=list[FeeChargeRead])
async def get_student_charges(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> list[FeeChargeRead]:
    charges = await StudentService(session).get_charges(student_id)
    return [FeeChargeRead.model_validate(c) for c in charges]


@router.get("/{student_id}/scholarships", response_model=list[ScholarshipAwardRead])
async def get_student_scholarships(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> list[ScholarshipAwardRead]:
    awards = await StudentService(session).get_scholarships(student_id)
    return [ScholarshipAwardRead.model_validate(a) for a in awards]


@router.get("/{student_id}/payments", response_model=list[PaymentRead])
async def get_student_payments(
    student_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> list[PaymentRead]:
    payments = await StudentService(session).get_payments(student_id)
    return [PaymentRead.model_validate(p) for p in payments]


# ── Attendance (STUDENT views own, LECTURER/ADMIN views any) ──────────────────


@router.get("/{student_id}/attendance", response_model=list[AttendanceRecordRead])
async def get_student_attendance(
    student_id: UUID,
    course_id: UUID | None = Query(None),
    session: AsyncSession = Depends(db_session),
    _=Depends(own_student_or_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR", "LECTURER")),
) -> list[AttendanceRecordRead]:
    records = await StudentService(session).get_attendance(student_id, course_id)
    return [AttendanceRecordRead.model_validate(r) for r in records]


# ── Applicants ─────────────────────────────────────────────────────────────────


@router.post("/applicants", response_model=ApplicantRead, status_code=201)
async def create_applicant(
    payload: ApplicantCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> ApplicantRead:
    applicant = await ApplicantService(session).create(payload)
    return ApplicantRead.model_validate(applicant)


@router.get("/applicants", response_model=list[ApplicantRead])
async def list_applicants(
    application_status: str | None = Query(None),
    program_id: UUID | None = Query(None),
    limit: int = Query(100, le=500),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> list[ApplicantRead]:
    applicants = await ApplicantService(session).list(application_status, program_id, limit, offset)
    return [ApplicantRead.model_validate(a) for a in applicants]


@router.get("/applicants/{applicant_id}", response_model=ApplicantRead)
async def get_applicant(
    applicant_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> ApplicantRead:
    applicant = await ApplicantService(session).get(applicant_id)
    return ApplicantRead.model_validate(applicant)


@router.patch("/applicants/{applicant_id}/status", response_model=ApplicantRead)
async def update_applicant_status(
    applicant_id: UUID,
    payload: ApplicantStatusUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> ApplicantRead:
    applicant = await ApplicantService(session).update_status(applicant_id, payload)
    return ApplicantRead.model_validate(applicant)


@router.post("/applicants/{applicant_id}/convert", response_model=StudentRead, status_code=201)
async def convert_applicant(
    applicant_id: UUID,
    payload: ApplicantConvert,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> StudentRead:
    student = await ApplicantService(session).convert(applicant_id, payload)
    return StudentRead.model_validate(student)


@router.post(
    "/applicants/{applicant_id}/documents", response_model=ApplicantDocumentRead, status_code=201
)
async def add_document(
    applicant_id: UUID,
    doc_type: str = Form(...),
    file: UploadFile = File(...),
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> ApplicantDocumentRead:
    doc = await ApplicantService(session).upload_document(applicant_id, doc_type, file)
    return ApplicantDocumentRead.model_validate(doc)


@router.post(
    "/applicants/{applicant_id}/documents/metadata",
    response_model=ApplicantDocumentRead,
    status_code=201,
)
async def add_document_metadata(
    applicant_id: UUID,
    payload: ApplicantDocumentCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> ApplicantDocumentRead:
    doc = await ApplicantService(session).add_document(applicant_id, payload)
    return ApplicantDocumentRead.model_validate(doc)


@router.get("/applicants/{applicant_id}/documents", response_model=list[ApplicantDocumentRead])
async def list_documents(
    applicant_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> list[ApplicantDocumentRead]:
    docs = await ApplicantService(session).list_documents(applicant_id)
    return [ApplicantDocumentRead.model_validate(d) for d in docs]


@router.delete("/applicants/{applicant_id}/documents/{doc_id}", status_code=204)
async def delete_document(
    applicant_id: UUID,
    doc_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> None:
    await ApplicantService(session).delete_document(doc_id)
