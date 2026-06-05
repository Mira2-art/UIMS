from __future__ import annotations

from datetime import date
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import AuditLog, SystemConfig


class SystemConfigRepository(AsyncRepository[SystemConfig]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, SystemConfig)

    async def get_by_key(self, config_key: str) -> SystemConfig | None:
        result = await self.session.execute(
            select(SystemConfig).where(SystemConfig.config_key == config_key)
        )
        return result.scalar_one_or_none()


class AuditLogRepository(AsyncRepository[AuditLog]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, AuditLog)

    async def list_filtered(
        self,
        user_id: UUID | None = None,
        entity_type: str | None = None,
        action: str | None = None,
        date_from: date | None = None,
        date_to: date | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[AuditLog]:
        query = select(AuditLog).order_by(AuditLog.created_at.desc())
        if user_id:
            query = query.where(AuditLog.user_id == user_id)
        if entity_type:
            query = query.where(AuditLog.entity_type == entity_type)
        if action:
            query = query.where(AuditLog.action == action)
        if date_from:
            from sqlalchemy import Date, cast

            query = query.where(cast(AuditLog.created_at, Date) >= date_from)
        if date_to:
            from sqlalchemy import Date, cast

            query = query.where(cast(AuditLog.created_at, Date) <= date_to)
        result = await self.session.execute(query.offset(offset).limit(limit))
        return list(result.scalars().all())
