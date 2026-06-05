from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class FeeStructureCreate(BaseModel):
    fee_name: str
    fee_code: str
    fee_category: str = "TUITION"
    description: str | None = None
    amount: Decimal
    currency: str = "USD"
    applies_to: str = "ALL"
    program_id: UUID | None = None
    faculty_id: UUID | None = None
    level: int | None = None
    effective_from: date
    effective_until: date | None = None
    is_mandatory: bool = True


class FeeStructureUpdate(BaseModel):
    fee_name: str | None = None
    description: str | None = None
    amount: Decimal | None = None
    effective_until: date | None = None
    is_active: bool | None = None
    is_mandatory: bool | None = None


class FeeStructureRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    fee_structure_id: UUID
    fee_name: str
    fee_code: str
    fee_category: str
    description: str | None
    amount: Decimal
    currency: str
    applies_to: str
    program_id: UUID | None
    level: int | None
    effective_from: date
    effective_until: date | None
    is_mandatory: bool
    is_active: bool
    created_at: datetime
    updated_at: datetime


class FeeChargeCreate(BaseModel):
    student_id: UUID
    semester_id: UUID
    fee_structure_id: UUID
    amount: Decimal
    due_date: date | None = None
    description: str | None = None
    discount_amount: Decimal = Decimal("0.00")


class FeeChargeRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    charge_id: UUID
    student_id: UUID
    semester_id: UUID
    fee_structure_id: UUID
    amount: Decimal
    amount_paid: Decimal
    discount_amount: Decimal
    due_date: date | None
    description: str | None
    status: str
    created_at: datetime
    updated_at: datetime


class PaymentCreate(BaseModel):
    student_id: UUID
    charge_id: UUID
    amount: Decimal
    payment_method: str
    transaction_ref: str | None = None
    receipt_number: str | None = None
    notes: str | None = None


class PaymentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    payment_id: UUID
    student_id: UUID
    charge_id: UUID
    amount: Decimal
    payment_method: str
    transaction_ref: str | None
    payment_date: date
    receipt_number: str | None
    notes: str | None
    recorded_by: UUID
    is_reversed: bool
    reversed_at: datetime | None
    reversal_reason: str | None
    created_at: datetime
    updated_at: datetime


class ScholarshipCreate(BaseModel):
    name: str
    scholarship_type: str = "MERIT"
    description: str | None = None
    amount: Decimal | None = None
    percentage_coverage: Decimal | None = None
    eligibility_criteria: str | None = None
    max_recipients: int | None = None
    application_deadline: date | None = None


class ScholarshipRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    scholarship_id: UUID
    name: str
    scholarship_type: str
    description: str | None
    amount: Decimal | None
    percentage_coverage: Decimal | None
    is_active: bool
    created_at: datetime
    updated_at: datetime


class ScholarshipAwardCreate(BaseModel):
    student_id: UUID
    semester_id: UUID
    amount: Decimal = Decimal("0.00")
    percentage_coverage: Decimal | None = None
    notes: str | None = None


class ScholarshipAwardRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    award_id: UUID
    scholarship_id: UUID
    student_id: UUID
    semester_id: UUID
    amount: Decimal
    status: str
    award_date: date
    created_at: datetime
    updated_at: datetime


class OutstandingBalanceRead(BaseModel):
    student_id: UUID
    total_charges: Decimal
    total_paid: Decimal
    outstanding: Decimal


class CollectionReportRead(BaseModel):
    total_payments: int
    total_collected: Decimal
    total_reversed: Decimal
    net_collected: Decimal


class DiscountUpdate(BaseModel):
    discount_amount: Decimal
