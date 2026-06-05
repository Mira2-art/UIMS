from __future__ import annotations

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import AttendanceRecord, AttendanceSession, AttendanceStatus
from app.modules.attendance.repository import (
    AttendanceRecordRepository,
    AttendanceSessionRepository,
)
from app.modules.attendance.schemas import (
    AttendanceSessionCreate,
    BulkAttendanceRequest,
    StudentAttendanceSummary,
)


class AttendanceService:
    def __init__(self, session: AsyncSession) -> None:
        self.session_repo = AttendanceSessionRepository(session)
        self.record_repo = AttendanceRecordRepository(session)

    async def create_session(
        self, payload: AttendanceSessionCreate, created_by: UUID
    ) -> AttendanceSession:
        att_session = AttendanceSession(
            course_id=payload.course_id,
            session_date=payload.session_date,
            topic=payload.topic,
            description=payload.description,
            created_by=created_by,
        )
        return await self.session_repo.create(att_session)

    async def list_sessions(self, course_id: UUID) -> list[AttendanceSession]:
        return await self.session_repo.list_by_course(course_id)

    async def bulk_record(
        self, session_id: UUID, payload: BulkAttendanceRequest, recorded_by: UUID
    ) -> list[AttendanceRecord]:
        await self.session_repo.get_or_404(session_id)
        results: list[AttendanceRecord] = []
        for item in payload.records:
            try:
                att_status = AttendanceStatus(item.status.upper())
            except ValueError as exc:
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST, f"Invalid attendance status: {item.status}"
                ) from exc
            existing = await self.record_repo.get_existing(session_id, item.student_id)
            if existing:
                existing.status = att_status
                existing.notes = item.notes
                record = await self.record_repo.update(existing)
            else:
                record = AttendanceRecord(
                    attendance_session_id=session_id,
                    student_id=item.student_id,
                    status=att_status,
                    recorded_by=recorded_by,
                    notes=item.notes,
                )
                record = await self.record_repo.create(record)
            results.append(record)
        return results

    async def get_session_records(self, session_id: UUID) -> list[AttendanceRecord]:
        await self.session_repo.get_or_404(session_id)
        return await self.record_repo.list_by_session(session_id)

    async def get_student_summary(
        self, student_id: UUID, course_id: UUID
    ) -> StudentAttendanceSummary:
        total = await self.record_repo.count_sessions_for_course(course_id)
        counts = await self.record_repo.count_by_status_for_student(student_id, course_id)
        present = counts.get("PRESENT", 0)
        late = counts.get("LATE", 0)
        absent = counts.get("ABSENT", 0)
        excused = counts.get("EXCUSED", 0)
        attended = present + late
        rate = (attended / total * 100) if total > 0 else 0.0
        return StudentAttendanceSummary(
            student_id=student_id,
            course_id=course_id,
            total_sessions=total,
            present=present,
            absent=absent,
            late=late,
            excused=excused,
            attendance_rate=round(rate, 2),
        )
