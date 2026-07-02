"""Idempotent data seed: system roles, client apps, and a bootstrap admin.

Run with:  python -m app.db.seed   (or `make seed`)

Safe to run repeatedly — it only inserts rows that don't already exist. Override
the bootstrap admin via SEED_ADMIN_EMAIL / SEED_ADMIN_PASSWORD env vars.
"""

from __future__ import annotations

import asyncio
import os
from datetime import date

from sqlalchemy import select

from app.core.security import hash_password
from app.db.session import SessionLocal
from app.db.sis_models import ClientApp, Role, Semester, User, UserRole, UserStatus

# role_code, role_name, description
_ROLES: list[tuple[str, str, str]] = [
    ("SUPER_ADMIN", "Super Administrator", "Full, unrestricted system access."),
    ("ADMIN", "Administrator", "System administration and configuration."),
    ("REGISTRAR", "Registrar", "Academic records, enrollment, and results."),
    ("DEAN", "Faculty Dean", "Faculty oversight; enters EXAM (/70) marks for the faculty's courses."),
    ("SECRETARIAT", "School Secretariat", "Records support; exam mark entry."),
    ("LECTURER", "Lecturer", "Teaching, attendance, and CA (/30) marks."),
    ("FINANCE", "Finance / Bursary", "Fees, charges, payments, and scholarships."),
    ("HR", "Human Resources", "Staff and lecturer records."),
    ("STAFF", "General Staff", "General staff access."),
    ("STUDENT", "Student", "Student self-service."),
]

# A single shared client app that every Trustech client (mobile + web) uses.
# The client_id below is what apps send as the `client_id` login/register field
# and the `X-Client-ID` header on authenticated requests. Override with
# SEED_CLIENT_ID if you want a different value in a given environment.
_CLIENT_ID = os.getenv("SEED_CLIENT_ID", "trustech_app")

# client_id, name, platform
_CLIENTS: list[tuple[str, str, str]] = [
    (_CLIENT_ID, "Trustech App", "all"),
]

_ADMIN_EMAIL = os.getenv("SEED_ADMIN_EMAIL", "admin@trustech.cm")
_ADMIN_PASSWORD = os.getenv("SEED_ADMIN_PASSWORD", "ChangeMe123!")


async def _ensure_roles(session) -> int:
    existing = set((await session.execute(select(Role.role_code))).scalars())
    created = 0
    for code, name, description in _ROLES:
        if code not in existing:
            session.add(
                Role(role_code=code, role_name=name, description=description, is_system=True)
            )
            created += 1
    return created


async def _ensure_clients(session) -> int:
    existing = set((await session.execute(select(ClientApp.client_id))).scalars())
    created = 0
    for client_id, name, platform in _CLIENTS:
        if client_id not in existing:
            session.add(
                ClientApp(client_id=client_id, name=name, platform=platform, is_active=True)
            )
            created += 1
    return created


async def _ensure_semesters(session) -> int:
    """Seed the current academic year's two semesters.

    Cameroon calendar: the academic year starts in **October**. Semester 1 runs
    Oct–Feb, Semester 2 Mar–Jul.
    """
    today = date.today()
    start_year = today.year if today.month >= 10 else today.year - 1
    ay = f"{start_year}/{start_year + 1}"
    month = today.month
    sem1_active = month >= 10 or month <= 2
    sem2_active = 3 <= month <= 7
    specs = [
        (1, f"{ay} First Semester", date(start_year, 10, 1), date(start_year + 1, 2, 15), sem1_active),
        (2, f"{ay} Second Semester", date(start_year + 1, 3, 1), date(start_year + 1, 7, 15), sem2_active),
    ]
    rows = (
        await session.execute(select(Semester.academic_year, Semester.semester_number))
    ).all()
    existing = {(r[0], r[1]) for r in rows}
    created = 0
    for number, name, start, end, active in specs:
        if (ay, number) in existing:
            continue
        session.add(
            Semester(
                name=name,
                academic_year=ay,
                semester_number=number,
                start_date=start,
                end_date=end,
                is_active=active,
                status="ACTIVE" if active else "UPCOMING",
            )
        )
        created += 1
    return created


async def _ensure_admin(session) -> bool:
    user = (
        await session.execute(select(User).where(User.email == _ADMIN_EMAIL))
    ).scalar_one_or_none()
    created = False
    if user is None:
        user = User(
            email=_ADMIN_EMAIL,
            password_hash=hash_password(_ADMIN_PASSWORD),
            first_name="System",
            last_name="Administrator",
            status=UserStatus.ACTIVE,
            email_verified=True,
        )
        session.add(user)
        await session.flush()  # populate user_id
        created = True

    super_role = (
        await session.execute(select(Role).where(Role.role_code == "SUPER_ADMIN"))
    ).scalar_one_or_none()
    if super_role is not None:
        link = (
            await session.execute(
                select(UserRole).where(
                    UserRole.user_id == user.user_id,
                    UserRole.role_id == super_role.role_id,
                )
            )
        ).scalar_one_or_none()
        if link is None:
            session.add(UserRole(user_id=user.user_id, role_id=super_role.role_id))
    return created


async def seed_all() -> None:
    from app.db.session import init_db

    await init_db()  # ensure tables exist (no-op on an Alembic'd Postgres; needed on SQLite)
    async with SessionLocal() as session:
        roles_added = await _ensure_roles(session)
        clients_added = await _ensure_clients(session)
        semesters_added = await _ensure_semesters(session)
        await session.flush()  # roles/clients visible for the admin link below
        admin_created = await _ensure_admin(session)
        await session.commit()

    print(
        f"Seed complete — +{roles_added} roles, +{clients_added} clients, "
        f"+{semesters_added} semesters, "
        f"admin {'created' if admin_created else 'already present'} ({_ADMIN_EMAIL})."
    )


if __name__ == "__main__":
    asyncio.run(seed_all())
