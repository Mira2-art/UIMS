from __future__ import annotations

from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.sis_models import (
    FeeCharge,
    FeeStatus,
    Payment,
    PaymentMethod,
    Scholarship,
    ScholarshipAward,
)
from app.modules.finance.repository import (
    FeeChargeRepository,
    FeeStructureRepository,
    PaymentRepository,
    ScholarshipAwardRepository,
    ScholarshipRepository,
)
from app.modules.finance.schemas import (
    FeeChargeCreate,
    FeeStructureCreate,
    FeeStructureUpdate,
    OutstandingBalanceRead,
    PaymentCreate,
    ScholarshipAwardCreate,
    ScholarshipCreate,
)


class FeeStructureService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = FeeStructureRepository(session)

    async def create(self, payload: FeeStructureCreate, created_by: UUID) -> object:
        from app.db.sis_models import FeeStructure

        if await self.repo.get_by_code(payload.fee_code):
            raise HTTPException(
                status.HTTP_409_CONFLICT, f"Fee code '{payload.fee_code}' already exists"
            )
        structure = FeeStructure(
            fee_name=payload.fee_name,
            fee_code=payload.fee_code.upper(),
            fee_category=payload.fee_category,
            description=payload.description,
            amount=payload.amount,
            currency=payload.currency,
            applies_to=payload.applies_to,
            program_id=payload.program_id,
            level=payload.level,
            effective_from=payload.effective_from,
            effective_until=payload.effective_until,
            is_mandatory=payload.is_mandatory,
            is_active=True,
            created_by=created_by,
        )
        return await self.repo.create(structure)

    async def list(self) -> list:
        return await self.repo.list()

    async def get(self, fee_structure_id: UUID) -> object:
        return await self.repo.get_or_404(fee_structure_id)

    async def update(self, fee_structure_id: UUID, payload: FeeStructureUpdate) -> object:
        structure = await self.repo.get_or_404(fee_structure_id)
        for field, value in payload.model_dump(exclude_none=True).items():
            setattr(structure, field, value)
        return await self.repo.update(structure)


class FeeChargeService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = FeeChargeRepository(session)

    async def create(self, payload: FeeChargeCreate) -> FeeCharge:
        charge = FeeCharge(
            student_id=payload.student_id,
            semester_id=payload.semester_id,
            fee_structure_id=payload.fee_structure_id,
            amount=payload.amount,
            amount_paid=Decimal("0.00"),
            discount_amount=payload.discount_amount,
            due_date=payload.due_date,
            description=payload.description,
            status=FeeStatus.OUTSTANDING,
        )
        return await self.repo.create(charge)

    async def list(self) -> list:
        return await self.repo.list()

    async def get(self, charge_id: UUID) -> FeeCharge:
        return await self.repo.get_or_404(charge_id)

    async def get_student_charges(self, student_id: UUID) -> list:
        return await self.repo.list_by_student(student_id)

    async def get_outstanding(self) -> list[OutstandingBalanceRead]:
        rows = await self.repo.get_outstanding_summary()
        return [OutstandingBalanceRead(**r) for r in rows]

    async def update_discount(self, charge_id: UUID, discount_amount) -> FeeCharge:
        from decimal import Decimal

        charge = await self.repo.get_or_404(charge_id)
        charge.discount_amount = Decimal(str(discount_amount))
        balance = charge.amount - charge.discount_amount - charge.amount_paid
        if balance <= Decimal("0"):
            charge.status = FeeStatus.PAID
        elif charge.amount_paid > Decimal("0"):
            charge.status = FeeStatus.PARTIAL
        return await self.repo.update(charge)


class PaymentService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = PaymentRepository(session)
        self.charge_repo = FeeChargeRepository(session)

    async def create(self, payload: PaymentCreate, recorded_by: UUID) -> Payment:
        try:
            method = PaymentMethod(payload.payment_method)
        except ValueError as exc:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, f"Invalid payment method: {payload.payment_method}"
            ) from exc

        charge = await self.charge_repo.get_or_404(payload.charge_id)

        if payload.receipt_number and await self.repo.get_by_receipt(payload.receipt_number):
            raise HTTPException(status.HTTP_409_CONFLICT, "Receipt number already exists")

        payment = Payment(
            student_id=payload.student_id,
            charge_id=payload.charge_id,
            amount=payload.amount,
            payment_method=method,
            transaction_ref=payload.transaction_ref,
            receipt_number=payload.receipt_number,
            notes=payload.notes,
            recorded_by=recorded_by,
            is_reversed=False,
        )
        payment = await self.repo.create(payment)
        charge.amount_paid += payload.amount
        balance = charge.amount - charge.discount_amount - charge.amount_paid
        if balance <= Decimal("0"):
            charge.status = FeeStatus.PAID
        else:
            charge.status = FeeStatus.PARTIAL
        await self.charge_repo.update(charge)
        return payment

    async def list(self) -> list:
        return await self.repo.list()

    async def get(self, payment_id: UUID) -> Payment:
        return await self.repo.get_or_404(payment_id)

    async def reverse(self, payment_id: UUID, reason: str | None = None) -> Payment:
        payment = await self.repo.get_or_404(payment_id)
        if payment.is_reversed:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Payment is already reversed")
        charge = await self.charge_repo.get_or_404(payment.charge_id)
        payment.is_reversed = True
        payment.reversed_at = datetime.now(UTC)
        payment.reversal_reason = reason
        charge.amount_paid -= payment.amount
        if charge.amount_paid < Decimal("0"):
            charge.amount_paid = Decimal("0")
        charge.status = (
            FeeStatus.OUTSTANDING if charge.amount_paid == Decimal("0") else FeeStatus.PARTIAL
        )
        await self.charge_repo.update(charge)
        return await self.repo.update(payment)

    async def get_collection_report(self):
        from app.modules.finance.schemas import CollectionReportRead

        data = await self.repo.get_collection_summary()
        return CollectionReportRead(**data)


class ScholarshipService:
    def __init__(self, session: AsyncSession) -> None:
        self.repo = ScholarshipRepository(session)
        self.award_repo = ScholarshipAwardRepository(session)

    async def create(self, payload: ScholarshipCreate, created_by: UUID) -> Scholarship:
        scholarship = Scholarship(
            name=payload.name,
            scholarship_type=payload.scholarship_type,
            description=payload.description,
            amount=payload.amount,
            percentage_coverage=payload.percentage_coverage,
            eligibility_criteria=payload.eligibility_criteria,
            max_recipients=payload.max_recipients,
            application_deadline=payload.application_deadline,
            is_active=True,
            created_by=created_by,
        )
        return await self.repo.create(scholarship)

    async def list(self) -> list:
        return await self.repo.list()

    async def award(
        self, scholarship_id: UUID, payload: ScholarshipAwardCreate, approved_by: UUID
    ) -> ScholarshipAward:
        await self.repo.get_or_404(scholarship_id)
        award = ScholarshipAward(
            scholarship_id=scholarship_id,
            student_id=payload.student_id,
            semester_id=payload.semester_id,
            amount=payload.amount,
            percentage_coverage=payload.percentage_coverage,
            notes=payload.notes,
            status="ACTIVE",
            approved_by=approved_by,
        )
        return await self.award_repo.create(award)

    async def get_student_awards(self, student_id: UUID) -> list:
        return await self.award_repo.list_by_student(student_id)
