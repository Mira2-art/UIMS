from __future__ import annotations

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import Applicant, ApplicantDocument, Enrollment, Student


class StudentRepository(AsyncRepository[Student]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Student)

    async def get_by_matric_no(self, matric_no: str) -> Student | None:
        result = await self.session.execute(select(Student).where(Student.matric_no == matric_no))
        return result.scalar_one_or_none()

    async def get_by_user_id(self, user_id: UUID) -> Student | None:
        result = await self.session.execute(select(Student).where(Student.user_id == user_id))
        return result.scalar_one_or_none()

    async def list_filtered(
        self,
        program_id: UUID | None = None,
        level: int | None = None,
        status: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Student]:
        query = select(Student)
        if program_id:
            query = query.where(Student.program_id == program_id)
        if level:
            query = query.where(Student.level == level)
        if status:
            query = query.where(Student.status == status)
        result = await self.session.execute(query.offset(offset).limit(limit))
        return list(result.scalars().all())

    async def count_enrollments(self, student_id: UUID) -> int:
        result = await self.session.execute(
            select(func.count()).select_from(Enrollment).where(Enrollment.student_id == student_id)
        )
        return result.scalar_one() or 0


class ApplicantRepository(AsyncRepository[Applicant]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Applicant)

    async def get_by_application_no(self, application_no: str) -> Applicant | None:
        result = await self.session.execute(
            select(Applicant).where(Applicant.application_no == application_no)
        )
        return result.scalar_one_or_none()

    async def list_filtered(
        self,
        application_status: str | None = None,
        program_id: UUID | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Applicant]:
        query = select(Applicant)
        if application_status:
            query = query.where(Applicant.application_status == application_status)
        if program_id:
            query = query.where(Applicant.program_id == program_id)
        result = await self.session.execute(query.offset(offset).limit(limit))
        return list(result.scalars().all())


class ApplicantDocumentRepository(AsyncRepository[ApplicantDocument]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, ApplicantDocument)

    async def list_by_applicant(self, applicant_id: UUID) -> list[ApplicantDocument]:
        result = await self.session.execute(
            select(ApplicantDocument).where(ApplicantDocument.applicant_id == applicant_id)
        )
        return list(result.scalars().all())
