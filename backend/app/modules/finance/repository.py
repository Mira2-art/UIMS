from __future__ import annotations

from decimal import Decimal
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.repositories import AsyncRepository
from app.db.sis_models import (
    FeeCharge,
    FeeStatus,
    FeeStructure,
    Payment,
    Scholarship,
    ScholarshipAward,
)


class FeeStructureRepository(AsyncRepository[FeeStructure]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, FeeStructure)

    async def get_by_code(self, fee_code: str) -> FeeStructure | None:
        result = await self.session.execute(
            select(FeeStructure).where(FeeStructure.fee_code == fee_code)
        )
        return result.scalar_one_or_none()


class FeeChargeRepository(AsyncRepository[FeeCharge]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, FeeCharge)

    async def list_by_student(self, student_id: UUID) -> list[FeeCharge]:
        result = await self.session.execute(
            select(FeeCharge).where(FeeCharge.student_id == student_id)
        )
        return list(result.scalars().all())

    async def get_outstanding_summary(self) -> list[dict]:
        result = await self.session.execute(
            select(
                FeeCharge.student_id,
                func.sum(FeeCharge.amount).label("total_charges"),
                func.sum(FeeCharge.amount_paid).label("total_paid"),
            )
            .where(FeeCharge.status != FeeStatus.PAID)
            .group_by(FeeCharge.student_id)
        )
        rows = result.all()
        return [
            {
                "student_id": r.student_id,
                "total_charges": r.total_charges or Decimal("0"),
                "total_paid": r.total_paid or Decimal("0"),
                "outstanding": (r.total_charges or Decimal("0")) - (r.total_paid or Decimal("0")),
            }
            for r in rows
        ]


class PaymentRepository(AsyncRepository[Payment]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Payment)

    async def get_by_receipt(self, receipt_number: str) -> Payment | None:
        result = await self.session.execute(
            select(Payment).where(Payment.receipt_number == receipt_number)
        )
        return result.scalar_one_or_none()

    async def list_by_student(self, student_id: UUID) -> list[Payment]:
        result = await self.session.execute(select(Payment).where(Payment.student_id == student_id))
        return list(result.scalars().all())

    async def get_collection_summary(self) -> dict:
        from decimal import Decimal

        result = await self.session.execute(
            select(
                func.count().label("total_payments"),
                func.coalesce(func.sum(Payment.amount), 0).label("total_collected"),
                func.coalesce(
                    func.sum(Payment.amount).filter(Payment.is_reversed.is_(True)), 0
                ).label("total_reversed"),
            )
        )
        row = result.one()
        total = Decimal(str(row.total_collected))
        reversed_amt = Decimal(str(row.total_reversed))
        return {
            "total_payments": row.total_payments,
            "total_collected": total,
            "total_reversed": reversed_amt,
            "net_collected": total - reversed_amt,
        }


class ScholarshipRepository(AsyncRepository[Scholarship]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Scholarship)


class ScholarshipAwardRepository(AsyncRepository[ScholarshipAward]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, ScholarshipAward)

    async def list_by_student(self, student_id: UUID) -> list[ScholarshipAward]:
        result = await self.session.execute(
            select(ScholarshipAward).where(ScholarshipAward.student_id == student_id)
        )
        return list(result.scalars().all())
