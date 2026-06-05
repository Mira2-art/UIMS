from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.grades.schemas import (
    AcademicStandingCreate,
    AcademicStandingRead,
    AssessmentCreate,
    AssessmentRead,
    AssessmentUpdate,
    GradeRead,
    GradeSubmit,
)
from app.modules.grades.service import AssessmentService, GradeService, StandingService

router = APIRouter()

# ── Assessments ────────────────────────────────────────────────────────────────


@router.post("/assessments", response_model=AssessmentRead, status_code=201)
async def create_assessment(
    payload: AssessmentCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "LECTURER")),
) -> AssessmentRead:
    assessment = await AssessmentService(session).create(payload, current_user.user_id)
    return AssessmentRead.model_validate(assessment)


@router.get("/assessments", response_model=list[AssessmentRead])
async def list_assessments(
    course_id: UUID = Query(...),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[AssessmentRead]:
    assessments = await AssessmentService(session).list(course_id)
    return [AssessmentRead.model_validate(a) for a in assessments]


@router.get("/assessments/{assessment_id}", response_model=AssessmentRead)
async def get_assessment(
    assessment_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> AssessmentRead:
    assessment = await AssessmentService(session).get(assessment_id)
    return AssessmentRead.model_validate(assessment)


@router.put("/assessments/{assessment_id}", response_model=AssessmentRead)
async def update_assessment(
    assessment_id: UUID,
    payload: AssessmentUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "LECTURER")),
) -> AssessmentRead:
    assessment = await AssessmentService(session).update(assessment_id, payload)
    return AssessmentRead.model_validate(assessment)


# ── Grades ─────────────────────────────────────────────────────────────────────


@router.post("", response_model=GradeRead, status_code=201)
async def submit_grade(
    payload: GradeSubmit,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "LECTURER")),
) -> GradeRead:
    grade = await GradeService(session).submit(payload)
    return GradeRead.model_validate(grade)


@router.get("", response_model=list[GradeRead])
async def list_grades(
    course_id: UUID | None = Query(None),
    student_id: UUID | None = Query(None),
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[GradeRead]:
    grades = await GradeService(session).list(course_id, student_id)
    return [GradeRead.model_validate(g) for g in grades]


@router.patch("/{grade_id}/publish", response_model=GradeRead)
async def publish_grade(
    grade_id: UUID,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "LECTURER")),
) -> GradeRead:
    grade = await GradeService(session).publish(grade_id, current_user.user_id)
    return GradeRead.model_validate(grade)


# ── Standings ──────────────────────────────────────────────────────────────────


@router.post("/standings", response_model=AcademicStandingRead, status_code=201)
async def compute_standing(
    payload: AcademicStandingCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> AcademicStandingRead:
    standing = await StandingService(session).compute_and_record(payload)
    return AcademicStandingRead.model_validate(standing)
