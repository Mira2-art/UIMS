from __future__ import annotations

from datetime import date
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import AuditLog, SystemConfig
from app.modules.administration.repository import AuditLogRepository, SystemConfigRepository
from app.modules.administration.schemas import SystemConfigUpdate


class SystemConfigService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = SystemConfigRepository(session)

    async def list(self) -> list[SystemConfig]:
        return await self.repo.list()

    async def get_by_key(self, config_key: str) -> SystemConfig:
        cfg = await self.repo.get_by_key(config_key)
        if not cfg:
            raise HTTPException(status.HTTP_404_NOT_FOUND, f"Config key '{config_key}' not found")
        return cfg

    async def update(
        self, config_key: str, payload: SystemConfigUpdate, updated_by: UUID
    ) -> SystemConfig:
        cfg = await self.get_by_key(config_key)
        if not cfg.is_editable:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "This config is not editable")
        cfg.config_value = payload.config_value
        cfg.updated_by = updated_by
        return await self.repo.update(cfg)


class AuditLogService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = AuditLogRepository(session)

    async def list(
        self,
        user_id: UUID | None = None,
        entity_type: str | None = None,
        action: str | None = None,
        date_from: date | None = None,
        date_to: date | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[AuditLog]:
        return await self.repo.list_filtered(
            user_id, entity_type, action, date_from, date_to, limit, offset
        )

    async def get(self, audit_id: UUID) -> AuditLog:
        return await self.repo.get_or_404(audit_id)

    @staticmethod
    async def record(
        session: AsyncSession,
        user_id: UUID | None,
        action: str,
        entity_type: str,
        entity_id: UUID | None = None,
        changes_summary: str | None = None,
        ip_address: str | None = None,
    ) -> None:
        log = AuditLog(
            user_id=user_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            changes_summary=changes_summary,
            ip_address=ip_address,
        )
        session.add(log)
        await session.commit()


class ReportService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def user_report(self) -> list[dict]:
        from sqlalchemy import func, select

        from app.db.sis_models import User

        result = await self.session.execute(
            select(User.status, func.count().label("count")).group_by(User.status)
        )
        return [{"status": str(r.status), "count": r.count} for r in result.all()]

    async def enrollment_report(self) -> list[dict]:
        from sqlalchemy import func, select

        from app.db.sis_models import Enrollment, EnrollmentStatus

        result = await self.session.execute(
            select(
                Enrollment.course_id.label("semester_id"),
                func.count().label("total_enrollments"),
                func.count().filter(Enrollment.status == EnrollmentStatus.ACTIVE).label("active"),
                func.count().filter(Enrollment.status == EnrollmentStatus.DROPPED).label("dropped"),
            ).group_by(Enrollment.course_id)
        )
        return [
            {
                "semester_id": r.semester_id,
                "total_enrollments": r.total_enrollments,
                "active": r.active,
                "dropped": r.dropped,
            }
            for r in result.all()
        ]
