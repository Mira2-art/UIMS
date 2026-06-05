from datetime import date
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, require_roles
from app.modules.administration.schemas import (
    AuditLogRead,
    EnrollmentReportRead,
    SystemConfigRead,
    SystemConfigUpdate,
    UserReportRead,
)
from app.modules.administration.service import AuditLogService, ReportService, SystemConfigService

router = APIRouter()

# ── System Configs (ADMIN / SUPER_ADMIN) ──────────────────────────────────────


@router.get("/configs", response_model=list[SystemConfigRead])
async def list_configs(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> list[SystemConfigRead]:
    configs = await SystemConfigService(session).list()
    return [SystemConfigRead.model_validate(c) for c in configs]


@router.get("/configs/{config_key}", response_model=SystemConfigRead)
async def get_config(
    config_key: str,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> SystemConfigRead:
    cfg = await SystemConfigService(session).get_by_key(config_key)
    return SystemConfigRead.model_validate(cfg)


@router.put("/configs/{config_key}", response_model=SystemConfigRead)
async def update_config(
    config_key: str,
    payload: SystemConfigUpdate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("SUPER_ADMIN")),
) -> SystemConfigRead:
    cfg = await SystemConfigService(session).update(config_key, payload, current_user.user_id)
    return SystemConfigRead.model_validate(cfg)


# ── Audit Logs (ADMIN / SUPER_ADMIN) ──────────────────────────────────────────


@router.get("/audit-logs", response_model=list[AuditLogRead])
async def list_audit_logs(
    user_id: UUID | None = Query(None),
    entity_type: str | None = Query(None),
    action: str | None = Query(None),
    date_from: date | None = Query(None),
    date_to: date | None = Query(None),
    limit: int = Query(100, le=500),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> list[AuditLogRead]:
    logs = await AuditLogService(session).list(
        user_id, entity_type, action, date_from, date_to, limit, offset
    )
    return [AuditLogRead.model_validate(log) for log in logs]


@router.get("/audit-logs/{audit_id}", response_model=AuditLogRead)
async def get_audit_log(
    audit_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> AuditLogRead:
    log = await AuditLogService(session).get(audit_id)
    return AuditLogRead.model_validate(log)


# ── Reports (ADMIN / SUPER_ADMIN) ─────────────────────────────────────────────


@router.get("/reports/users", response_model=list[UserReportRead])
async def user_report(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN")),
) -> list[UserReportRead]:
    data = await ReportService(session).user_report()
    return [UserReportRead(**row) for row in data]


@router.get("/reports/enrollments", response_model=list[EnrollmentReportRead])
async def enrollment_report(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "REGISTRAR")),
) -> list[EnrollmentReportRead]:
    data = await ReportService(session).enrollment_report()
    return [EnrollmentReportRead(**row) for row in data]
