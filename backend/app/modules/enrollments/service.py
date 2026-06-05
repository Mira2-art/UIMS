from __future__ import annotations

from datetime import date
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import Course, Enrollment, EnrollmentStatus, Prerequisite
from app.modules.enrollments.repository import EnrollmentRepository
from app.modules.enrollments.schemas import DropEnrollmentRequest, EnrollmentCreate, WithdrawRequest


class EnrollmentService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = EnrollmentRepository(session)

    async def _check_prerequisites(self, student_id: UUID, course_id: UUID) -> None:
        result = await self.repo.session.execute(
            select(Prerequisite).where(
                Prerequisite.course_id == course_id,
                Prerequisite.is_strict.is_(True),
                Prerequisite.is_corequisite.is_(False),
            )
        )
        prereqs = result.scalars().all()
        for prereq in prereqs:
            completed = await self.repo.session.execute(
                select(Enrollment).where(
                    Enrollment.student_id == student_id,
                    Enrollment.course_id == prereq.prereq_course_id,
                    Enrollment.status == EnrollmentStatus.COMPLETED,
                )
            )
            if not completed.scalar_one_or_none():
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST,
                    f"Prerequisite course not completed (prereq_course_id={prereq.prereq_course_id})",
                )

    async def _check_registration_window(self, course_id: UUID) -> None:
        from app.db.sis_models import Semester

        course = await self.repo.session.get(Course, course_id)
        if not course:
            return
        semester = await self.repo.session.get(Semester, course.semester_id)
        if not semester:
            return
        today = date.today()
        if semester.registration_start and today < semester.registration_start:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Registration opens on {semester.registration_start}",
            )
        if semester.registration_end and today > semester.registration_end:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Registration closed on {semester.registration_end}",
            )

    async def create(self, payload: EnrollmentCreate, enforce_window: bool = False) -> Enrollment:
        existing = await self.repo.get_by_student_course(payload.student_id, payload.course_id)
        if existing and existing.status == EnrollmentStatus.ACTIVE:
            raise HTTPException(
                status.HTTP_409_CONFLICT, "Student is already enrolled in this course"
            )

        course = await self.repo.session.get(Course, payload.course_id)
        if not course:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Course not found")
        if course.current_enrollment >= course.max_capacity:
            raise HTTPException(status.HTTP_409_CONFLICT, "Course has reached maximum capacity")

        if enforce_window:
            await self._check_registration_window(payload.course_id)

        await self._check_prerequisites(payload.student_id, payload.course_id)

        enrollment = Enrollment(
            student_id=payload.student_id,
            course_id=payload.course_id,
            enrolled_by=payload.enrolled_by,
            status=EnrollmentStatus.ACTIVE,
        )
        enrollment = await self.repo.create(enrollment)
        course.current_enrollment += 1
        await self.repo.session.commit()
        return enrollment

    async def list(
        self,
        student_id: UUID | None = None,
        course_id: UUID | None = None,
        enroll_status: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Enrollment]:
        return await self.repo.list_filtered(student_id, course_id, enroll_status, limit, offset)

    async def get(self, enrollment_id: UUID) -> Enrollment:
        return await self.repo.get_or_404(enrollment_id)

    async def drop(self, enrollment_id: UUID, payload: DropEnrollmentRequest) -> Enrollment:
        enrollment = await self.repo.get_or_404(enrollment_id)
        if enrollment.status != EnrollmentStatus.ACTIVE:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "Only ACTIVE enrollments can be dropped"
            )
        enrollment.status = EnrollmentStatus.DROPPED
        enrollment.drop_date = date.today()
        enrollment.drop_reason = payload.drop_reason
        enrollment = await self.repo.update(enrollment)
        course = await self.repo.session.get(Course, enrollment.course_id)
        if course and course.current_enrollment > 0:
            course.current_enrollment -= 1
            await self.repo.session.commit()
        return enrollment

    async def withdraw(self, enrollment_id: UUID, payload: WithdrawRequest) -> Enrollment:
        enrollment = await self.repo.get_or_404(enrollment_id)
        if enrollment.status not in (EnrollmentStatus.ACTIVE, EnrollmentStatus.DROPPED):
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot withdraw from this enrollment")
        enrollment.status = EnrollmentStatus.WITHDRAWN
        enrollment.drop_date = date.today()
        enrollment.drop_reason = payload.reason
        enrollment = await self.repo.update(enrollment)
        if enrollment.status == EnrollmentStatus.ACTIVE:
            course = await self.repo.session.get(Course, enrollment.course_id)
            if course and course.current_enrollment > 0:
                course.current_enrollment -= 1
                await self.repo.session.commit()
        return enrollment

    async def complete(self, enrollment_id: UUID) -> Enrollment:
        enrollment = await self.repo.get_or_404(enrollment_id)
        if enrollment.status != EnrollmentStatus.ACTIVE:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "Only ACTIVE enrollments can be marked complete"
            )
        enrollment.status = EnrollmentStatus.COMPLETED
        return await self.repo.update(enrollment)
