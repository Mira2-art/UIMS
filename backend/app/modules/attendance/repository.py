from __future__ import annotations

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import AttendanceRecord, AttendanceSession, AttendanceStatus


class AttendanceSessionRepository(AsyncRepository[AttendanceSession]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, AttendanceSession)

    async def list_by_course(self, course_id: UUID) -> list[AttendanceSession]:
        result = await self.session.execute(
            select(AttendanceSession).where(AttendanceSession.course_id == course_id)
        )
        return list(result.scalars().all())


class AttendanceRecordRepository(AsyncRepository[AttendanceRecord]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, AttendanceRecord)

    async def list_by_session(self, session_id: UUID) -> list[AttendanceRecord]:
        result = await self.session.execute(
            select(AttendanceRecord).where(AttendanceRecord.attendance_session_id == session_id)
        )
        return list(result.scalars().all())

    async def get_existing(self, session_id: UUID, student_id: UUID) -> AttendanceRecord | None:
        result = await self.session.execute(
            select(AttendanceRecord).where(
                AttendanceRecord.attendance_session_id == session_id,
                AttendanceRecord.student_id == student_id,
            )
        )
        return result.scalar_one_or_none()

    async def count_by_status_for_student(
        self, student_id: UUID, course_id: UUID
    ) -> dict[str, int]:
        counts: dict[str, int] = {}
        for att_status in AttendanceStatus:
            result = await self.session.execute(
                select(func.count())
                .select_from(AttendanceRecord)
                .join(
                    AttendanceSession,
                    AttendanceSession.attendance_session_id
                    == AttendanceRecord.attendance_session_id,
                )
                .where(
                    AttendanceRecord.student_id == student_id,
                    AttendanceSession.course_id == course_id,
                    AttendanceRecord.status == att_status,
                )
            )
            counts[att_status.value] = result.scalar_one() or 0
        return counts

    async def count_sessions_for_course(self, course_id: UUID) -> int:
        result = await self.session.execute(
            select(func.count())
            .select_from(AttendanceSession)
            .where(AttendanceSession.course_id == course_id)
        )
        return result.scalar_one() or 0
