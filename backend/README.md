# FastAPI Backend Scaffold

Senior-style async FastAPI setup with clear separation of concerns and 7 modules:

- auth
- users
- students
- teachers
- courses
- enrollments
- grades

## Architecture

- `app/main.py`: app startup, lifespan, middleware wiring.
- `app/core`: settings, logging, security helpers.
- `app/db`: async engine/session, base ORM, common repositories.
- `app/api/v1`: versioned API root and health endpoint.
- `app/modules/*`: module-level routers, services, repositories, schemas, models.
- `alembic`: migration config.

## Run

```bash
cd backend
cp .env.example .env
uvicorn app.main:app --reload
```

> Full setup / run / migrate / seed / lint / format / test / celery guide:
> **[`docs/run.md`](docs/run.md)**. First run: `cd backend && alembic upgrade head && make seed && make test`.

## Migrations

```bash
cd backend
alembic revision --autogenerate -m "init"
alembic upgrade head
```

## Seed (roles, client apps, bootstrap admin)

The auth layer needs registered **client apps** (`X-Client-ID`) and the
**role codes** the API gates on. Seed them (idempotent — safe to re-run):

```bash
cd backend
make seed          # or: python -m app.db.seed
```

Seeds:
- **Roles** (system): `SUPER_ADMIN, ADMIN, REGISTRAR, DEAN, SECRETARIAT, LECTURER, FINANCE, HR, STAFF, STUDENT`.
- **Client apps**: `trustech_mobile_client` (student), `trustech_staff_client` (staff/pro), `trustech_web_client`.
- **Bootstrap admin**: `admin@trustech.local` / `ChangeMe123!` (override via `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD`; change the password after first login).

Assign dual roles (e.g. a lecturer who is also a faculty dean) by giving the
user both role codes — the API checks role sets, so `dean/lecturer`,
`registrar/lecturer`, `admin/lecturer` all work out of the box.

## Grading model (CA + EXAM)

Final course mark = **CA (max 30, entered by `LECTURER`)** + **EXAM (max 70,
entered by `DEAN` / `REGISTRAR` / `ADMIN`, scoped to the course's faculty)** =
**/100 → letter** (A+ ≥96, A ≥80, B+ ≥70, B ≥60, C+ ≥55, C ≥50, D+ ≥45, D ≥40,
else F). See `app/modules/grades/service.py`; unit-tested in
`tests/test_grades_scale.py` (`make test`).

**GPA / CGPA are computed automatically** (nobody enters a GPA) on a **4.0 scale**
(A+/A = 4.0, B+ = 3.5, B = 3.0, C+ = 2.5, C = 2.0, D+ = 1.5, D = 1.0, F = 0):
- **GPA** = Σ(grade-point × credit-units) / Σ(credit-units) over **that semester's** courses.
- **CGPA** = the same, **cumulative** across every graded semester (meaningful from the 2nd semester on).
- Only **finalized** courses count (an EXAM grade must be recorded).
- Standing (from CGPA): Dean's List ≥ 3.5, Good Standing ≥ 2.0, else Probation.
- Academic year starts in **October** (Cameroon); the seed creates the current year's two semesters (Oct–Feb, Mar–Jul).

## Test

```bash
cd backend
make test          # pytest -q
```
