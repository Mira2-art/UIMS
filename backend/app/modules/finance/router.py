from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import db_session, get_current_user, require_roles
from app.modules.finance.schemas import (
    CollectionReportRead,
    DiscountUpdate,
    FeeChargeCreate,
    FeeChargeRead,
    FeeStructureCreate,
    FeeStructureRead,
    FeeStructureUpdate,
    OutstandingBalanceRead,
    PaymentCreate,
    PaymentRead,
    ScholarshipAwardCreate,
    ScholarshipAwardRead,
    ScholarshipCreate,
    ScholarshipRead,
)
from app.modules.finance.service import (
    FeeChargeService,
    FeeStructureService,
    PaymentService,
    ScholarshipService,
)

router = APIRouter()

# ── Fee Structures ─────────────────────────────────────────────────────────────


@router.post("/fee-structures", response_model=FeeStructureRead, status_code=201)
async def create_fee_structure(
    payload: FeeStructureCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> FeeStructureRead:
    structure = await FeeStructureService(session).create(payload, current_user.user_id)
    return FeeStructureRead.model_validate(structure)


@router.get("/fee-structures", response_model=list[FeeStructureRead])
async def list_fee_structures(
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[FeeStructureRead]:
    structures = await FeeStructureService(session).list()
    return [FeeStructureRead.model_validate(s) for s in structures]


@router.get("/fee-structures/{fee_structure_id}", response_model=FeeStructureRead)
async def get_fee_structure(
    fee_structure_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> FeeStructureRead:
    structure = await FeeStructureService(session).get(fee_structure_id)
    return FeeStructureRead.model_validate(structure)


@router.put("/fee-structures/{fee_structure_id}", response_model=FeeStructureRead)
async def update_fee_structure(
    fee_structure_id: UUID,
    payload: FeeStructureUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> FeeStructureRead:
    structure = await FeeStructureService(session).update(fee_structure_id, payload)
    return FeeStructureRead.model_validate(structure)


# ── Fee Charges ────────────────────────────────────────────────────────────────


@router.post("/charges", response_model=FeeChargeRead, status_code=201)
async def create_charge(
    payload: FeeChargeCreate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> FeeChargeRead:
    charge = await FeeChargeService(session).create(payload)
    return FeeChargeRead.model_validate(charge)


@router.get("/charges", response_model=list[FeeChargeRead])
async def list_charges(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> list[FeeChargeRead]:
    charges = await FeeChargeService(session).list()
    return [FeeChargeRead.model_validate(c) for c in charges]


@router.get("/charges/{charge_id}", response_model=FeeChargeRead)
async def get_charge(
    charge_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> FeeChargeRead:
    charge = await FeeChargeService(session).get(charge_id)
    return FeeChargeRead.model_validate(charge)


@router.patch("/charges/{charge_id}/discount", response_model=FeeChargeRead)
async def update_discount(
    charge_id: UUID,
    payload: DiscountUpdate,
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> FeeChargeRead:
    charge = await FeeChargeService(session).update_discount(charge_id, payload.discount_amount)
    return FeeChargeRead.model_validate(charge)


# ── Payments ───────────────────────────────────────────────────────────────────


@router.post("/payments", response_model=PaymentRead, status_code=201)
async def record_payment(
    payload: PaymentCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> PaymentRead:
    payment = await PaymentService(session).create(payload, current_user.user_id)
    return PaymentRead.model_validate(payment)


@router.get("/payments", response_model=list[PaymentRead])
async def list_payments(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> list[PaymentRead]:
    payments = await PaymentService(session).list()
    return [PaymentRead.model_validate(p) for p in payments]


@router.get("/payments/{payment_id}", response_model=PaymentRead)
async def get_payment(
    payment_id: UUID,
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> PaymentRead:
    payment = await PaymentService(session).get(payment_id)
    return PaymentRead.model_validate(payment)


@router.patch("/payments/{payment_id}/reverse", response_model=PaymentRead)
async def reverse_payment(
    payment_id: UUID,
    reason: str | None = Query(None),
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> PaymentRead:
    payment = await PaymentService(session).reverse(payment_id, reason)
    return PaymentRead.model_validate(payment)


# ── Scholarships ───────────────────────────────────────────────────────────────


@router.post("/scholarships", response_model=ScholarshipRead, status_code=201)
async def create_scholarship(
    payload: ScholarshipCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> ScholarshipRead:
    scholarship = await ScholarshipService(session).create(payload, current_user.user_id)
    return ScholarshipRead.model_validate(scholarship)


@router.get("/scholarships", response_model=list[ScholarshipRead])
async def list_scholarships(
    session: AsyncSession = Depends(db_session),
    _=Depends(get_current_user),
) -> list[ScholarshipRead]:
    scholarships = await ScholarshipService(session).list()
    return [ScholarshipRead.model_validate(s) for s in scholarships]


@router.post(
    "/scholarships/{scholarship_id}/awards", response_model=ScholarshipAwardRead, status_code=201
)
async def award_scholarship(
    scholarship_id: UUID,
    payload: ScholarshipAwardCreate,
    session: AsyncSession = Depends(db_session),
    current_user=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> ScholarshipAwardRead:
    award = await ScholarshipService(session).award(scholarship_id, payload, current_user.user_id)
    return ScholarshipAwardRead.model_validate(award)


# ── Reports ────────────────────────────────────────────────────────────────────


@router.get("/reports/outstanding", response_model=list[OutstandingBalanceRead])
async def outstanding_balances(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> list[OutstandingBalanceRead]:
    return await FeeChargeService(session).get_outstanding()


@router.get("/reports/collection", response_model=CollectionReportRead)
async def collection_report(
    session: AsyncSession = Depends(db_session),
    _=Depends(require_roles("ADMIN", "SUPER_ADMIN", "FINANCE")),
) -> CollectionReportRead:
    return await PaymentService(session).get_collection_report()
