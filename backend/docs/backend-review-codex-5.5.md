# Backend Review - Codex 5.5

**Date:** 2026-06-05
**Scope:** FastAPI backend implementation versus `docs/arch.md`, `docs/srs.md`, and `docs/db-design.md`
**Status:** Early implementation with several real modules started, but not yet production-ready

---

## Executive Summary

The backend has moved beyond a scaffold. It now contains async FastAPI routing, a centralized SQLAlchemy model file with all 36 database tables from the database design, service/repository layers for most modules, authentication flows, finance, grades, attendance, communication, and academic structure endpoints.

The main issue is that the implementation is ahead in breadth but weak in release control and requirement alignment. The SQLAlchemy table coverage is good, but Alembic migrations are empty. Several protected endpoints cannot work with the seeded/documented role codes. MOD-5 admissions and enrollment portal requirements are only partially represented through generic applicant/student endpoints. High-risk domains like finance, enrollment capacity, GPA computation, and audit logging need stronger transaction handling and tests before real workloads.

---

## Verification Performed

Commands run:
- `cd backend && env/bin/pytest`
- `cd backend && PYTHONPATH=. env/bin/pytest`
- `cd backend && PYTHONPATH=. python3 -m compileall app tests`
- `cd backend && PYTHONPATH=. env/bin/python -c "...Base.metadata.tables..."`
- `cd backend && env/bin/python -m pip install -r requirements-extra.txt`
- `cd backend && env/bin/black app tests`
- `cd backend && env/bin/ruff check app tests --fix`
- `cd backend && env/bin/black --check app tests`
- `cd backend && env/bin/ruff check app tests`
- `cd backend && env/bin/python -m compileall app tests`
- `cd backend && env/bin/python -m pip check`
- `cd backend && env/bin/mypy app tests`

Results:
- Default test command originally failed: `ModuleNotFoundError: No module named 'app'`.
- This was fixed by adding `pythonpath = ["."]` to `pyproject.toml`; `cd backend && env/bin/pytest` now passes.
- With `PYTHONPATH=.`, tests pass: `1 passed`.
- Compile check passes.
- SQLAlchemy metadata loads **36 tables**, matching `docs/db-design.md`.
- Black and Ruff are now installed in `backend/env`.
- Black reformatted 39 files and now passes with `91 files would be left unchanged`.
- Ruff auto-fixed 19 lint issues; the remaining local issues were patched manually. Ruff now passes.
- `pip check` passes: no broken requirements found.
- `mypy` is installed but not clean yet: **31 errors in 15 files**, mostly missing third-party stubs and service method return type annotations.

---

## What Is Working

1. The backend is async-first: FastAPI routes use `AsyncSession`, async repositories, and async SQLAlchemy.
2. Central schema coverage is good: `app/db/sis_models.py` defines the 36 tables from the normalized DB design.
3. Route coverage has expanded across academic structure, auth, users, students, teachers, courses, enrollment, attendance, grades, finance, communication, and administration.
4. Authentication has real logic for registration, login, refresh, password reset, email verification, role assignment, and sessions.
5. Core service/repository separation exists and is generally consistent.
6. Redis, Celery, and email task scaffolding exist.

---

## Critical Findings

### 1. Alembic migration does not create the schema

File: `alembic/versions/4e6ea02da8ab_initial_schema.py:20`

`upgrade()` and `downgrade()` are empty. Running `alembic upgrade head` will not create any tables, enums, indexes, seed data, or constraints. This directly conflicts with the DB design requirement that schema evolution be migration-controlled.

Recommendation:
- Generate a real initial migration from SQLAlchemy metadata:
  - `PYTHONPATH=. alembic revision --autogenerate -m "initial schema"`
  - Review the generated migration carefully.
  - Add seed inserts for roles, core permissions, and essential `system_configs`.
- Do not rely on `AUTO_CREATE_TABLES=true` except for quick local experiments.

### 2. RBAC role codes do not match documented/seeded role codes

Files:
- `app/api/dependencies.py:75`
- `app/modules/auth/router.py:120`

The code checks roles like `ADMIN`, `SUPER_ADMIN`, `REGISTRAR`, `FINANCE`, and `STAFF`. The DB draft and architecture use codes like `ROLE_ADMIN_SYSTEM`, `ROLE_ADMIN_FINANCE`, `ROLE_ADMIN_DEPT`, `ROLE_STUDENT`, and `ROLE_LECTURER`.

Impact:
- A correctly seeded user with `ROLE_ADMIN_SYSTEM` will fail guards expecting `SUPER_ADMIN`.
- Many admin endpoints will be inaccessible after proper seed data is applied.

Recommendation:
- Create one canonical role code enum or constants module.
- Align all guards to the final codes.
- Seed the exact same codes in migration.
- Add tests proving each role can access the expected module routes.

### 3. Production schema currently depends on `create_all`

File: `app/db/session.py:21`

`init_db()` uses `Base.metadata.create_all`. This is acceptable for scratch development, but it bypasses migration history, seeds, data transformations, and reviewable schema diffs.

Recommendation:
- Keep `AUTO_CREATE_TABLES=false`.
- Remove `create_all` from normal app startup once migrations are ready.
- Use Alembic as the only production schema path.

### 4. MOD-5 admissions portal is only partially represented

Files:
- `app/modules/students/router.py:175`
- `app/modules/students/router.py:208`
- `app/modules/students/router.py:219`

Current support covers applicant create/list/get/status/convert and applicant documents. The screen inventory for the Admission & Student Enrollment Portal requires much more:
- public admissions content
- application stepper sections
- payment center
- admission officer dashboard
- document verification workflow
- interview management
- offer generation, dispatch, tracking
- offer accept/decline
- enrollment checklist and acceptance fee
- student ID generation workflow

Recommendation:
- Create a dedicated `app/modules/admissions/` module for MOD-5 admission workflows.
- Keep `students` focused on enrolled students.
- Add tables or models for application sections, reviews, interviews, offers, offer events, enrollment checklist, and admission payments if they are in scope for v1.

---

## High-Risk Findings

### 5. Enrollment capacity updates are not concurrency-safe

File: `app/modules/enrollments/service.py:68`

The service checks capacity, creates enrollment, then increments `course.current_enrollment` after a separate commit. Concurrent requests can pass the capacity check and over-enroll the course.

Recommendation:
- Wrap registration in one transaction.
- Lock the course row using `SELECT ... FOR UPDATE`.
- Re-check capacity inside the lock.
- Add a concurrency test for last-seat registration.

### 6. Withdraw does not decrement course enrollment count

File: `app/modules/enrollments/service.py:121`

`withdraw()` sets `enrollment.status = WITHDRAWN`, then checks `if enrollment.status == ACTIVE`, which will never be true. Active withdrawals will not reduce `current_enrollment`.

Recommendation:
- Capture the previous status before mutation.
- Decrement only if previous status was `ACTIVE`.
- Add tests for drop and withdraw count behavior.

### 7. Finance payment posting is not ledger-safe

File: `app/modules/finance/service.py:147`

Payment creation commits payment first, then updates `fee_charges.amount_paid` separately. Reversal mutates the payment row with `is_reversed=True` and directly subtracts from the charge.

Risk:
- Partial failure can leave payment and charge balance inconsistent.
- The DB design says posted transactions should be immutable and reversals should be compensating entries.

Recommendation:
- Use one transaction for payment and charge update.
- Add idempotency keys for gateway callbacks.
- Replace mutable reversal with a reversal transaction or ledger entry.
- Add overpayment validation against `amount - discount_amount - amount_paid`.

### 8. GPA/standing calculation is not reliable enough

File: `app/modules/grades/service.py:135`

The standing service does not filter by semester, computes a `weighted_score` that is unused, picks `max(letter_grade)` lexically, and does not truly compute CGPA across historical semesters.

Recommendation:
- Define grading policy in `system_configs` or a grading scale table.
- Compute course final score from assessment weights.
- Compute semester GPA by course credit units.
- Compute CGPA across completed semesters.
- Add golden-case tests for GPA, CGPA, probation, dean's list, and failed courses.

### 9. Grade publish does not trigger standing recalculation

File: `app/modules/grades/service.py:118`

Publishing a grade marks it published but does not update `academic_standings`. The DB design explicitly calls for standing recomputation when grades are published.

Recommendation:
- Either trigger recalculation from `GradeService.publish()` or queue a background job.
- Add tests proving published grades update standing.

### 10. Audit logging is incomplete

Files:
- `app/modules/auth/service.py:51`
- `app/db/sis_models.py:730`

Audit is manually called in some auth actions only. There is no consistent audit coverage for role changes, finance actions, grade changes, applicant decisions, or system config changes.

Recommendation:
- Add an `AuditService`.
- Require all high-risk services to emit audit events.
- Use a request-scoped actor context for user id, IP, and user agent.
- Add audit tests for finance, grades, RBAC, and admissions decisions.

---

## Medium-Risk Findings

### 11. Public requirements are protected behind authentication

The screen inventory requires public programme listing, programme details, admissions pages, scholarships, FAQ, and contact pages. Current academic structure listing routes require `get_current_user`.

Recommendation:
- Add a public API namespace, for example `/api/v1/public/...`.
- Expose safe read-only programme/faculty/department/admissions content without JWT.
- Keep admin write endpoints protected.

### 12. Password reset and email verification leak tokens in API responses

Files:
- `app/modules/auth/router.py:59`
- `app/modules/auth/router.py:101`

The API returns reset and verification tokens. This is useful during early testing, but it is not production-safe.

Recommendation:
- In development, optionally return tokens behind `ENVIRONMENT=development`.
- In production, return only generic success messages.
- Store verification tokens hashed like password reset tokens, or use a dedicated typed token table.

### 13. Email/Celery failures are swallowed

File: `app/modules/auth/service.py:81`

Email calls are wrapped in broad `except Exception: pass`, so operational failures disappear.

Recommendation:
- Log the exception with context.
- Store `email_logs`.
- Keep user-facing response stable, but preserve operational diagnostics.

### 14. `updated_at` will not update for most central SIS models

File: `app/db/sis_models.py:103`

Most central models define `updated_at` with only `server_default=func.now()`. The reusable `TimestampMixin` has `onupdate=func.now()`, but the central models do not use it.

Recommendation:
- Add `onupdate=func.now()` consistently or use a database trigger through migration.
- Add a test that updating a record changes `updated_at`.

### 15. Requirements and README are stale

File: `README.md`

README still says the backend has 7 modules, but the implementation and architecture now include many more module packages and 8 architecture modules.

Recommendation:
- Update README to match `docs/arch.md`.
- Add run/test/migration instructions with `PYTHONPATH=.` or package installation guidance.

### 16. Test configuration is incomplete

File: `tests/conftest.py:4`

Running `env/bin/pytest` from `backend/` originally failed unless `PYTHONPATH=.` was set. This has now been addressed by adding `pythonpath = ["."]` to pytest config.

Recommendation:
- Add integration tests for auth, role guards, migrations, DB models, admissions flow, enrollment, finance, and grades.

### 17. Dependency files are drifting

Files:
- `requirements.txt`
- `requirements-extra.txt`
- `app/core/celery_app.py`

Celery is used in code, but dependency tracking should be normalized. Black, Ruff, and MyPy have now been added to `requirements-extra.txt` and installed into `backend/env`.

Recommendation:
- Pick one source of truth: `requirements.txt` or `pyproject.toml` dependencies.
- Include Celery explicitly.
- Split optional groups later if needed: `dev`, `worker`, `test`.

### 18. Upload storage and email templates were missing

Files:
- `app/modules/students/router.py`
- `app/modules/students/service.py`
- `app/core/storage.py`
- `app/tasks/email.py`
- `templates/email/`
- `static/uploads/`

Previous state:
- Applicant documents accepted `file_path` and `file_name` as JSON metadata only.
- There was no `static/` directory mounted by FastAPI.
- Email HTML/text was embedded directly in Python task helpers.
- There was no `templates/` directory for reusable email templates.

Action taken:
- Added `static/` and mounted it at `/static`.
- Added `static/uploads/applicants/` as the baseline applicant document storage root.
- Added structured applicant upload storage:
  - `static/uploads/applicants/<applicant_id>/<doc_type>/<timestamp>_<uuid>_<safe_original_name>.<ext>`
- Added safe document type and filename normalization.
- Added multipart applicant document upload endpoint at:
  - `POST /api/v1/students/applicants/{applicant_id}/documents`
- Preserved metadata-only registration at:
  - `POST /api/v1/students/applicants/{applicant_id}/documents/metadata`
- Added `templates/email/` with HTML and plaintext versions for welcome, email verification, password reset, grade published, and fee reminder emails.
- Updated email task helpers to render through Jinja templates.

Remaining recommendation:
- Add MIME type allowlisting and virus scanning before production.
- Store original filename separately if the DB design is expanded; the current `file_name` stores the sanitized stored filename.
- Add upload integration tests with multipart form data.
- Add object storage abstraction later if deployment moves to S3, Cloudflare R2, MinIO, or similar.

---

## Latest Quality Check Results

Run on 2026-06-05:

| Check | Command | Result |
|---|---|---|
| Dev tool install | `cd backend && env/bin/python -m pip install -r requirements-extra.txt` | Passed: installed Black, Ruff, and MyPy |
| Black format | `cd backend && env/bin/black app tests` | Passed: reformatted 39 files |
| Black check | `cd backend && env/bin/black --check app tests` | Passed: 91 files unchanged |
| Ruff fix | `cd backend && env/bin/ruff check app tests --fix` | Partially passed: 19 issues auto-fixed, 13 required manual cleanup |
| Ruff check | `cd backend && env/bin/ruff check app tests` | Passed |
| Upload/template Black | `cd backend && env/bin/black app tests` | Passed: 93 files unchanged |
| Upload/template Ruff | `cd backend && env/bin/ruff check app tests` | Passed |
| Template smoke | `cd backend && env/bin/python - <<'PY' ... render_template(...)` | Passed |
| Pytest | `cd backend && env/bin/pytest` | Passed: `1 passed`, one `passlib` deprecation warning |
| Compile | `cd backend && env/bin/python -m compileall app tests` | Passed |
| Dependency consistency | `cd backend && env/bin/python -m pip check` | Passed |
| MyPy | `cd backend && env/bin/mypy app tests` | Failed: 31 errors in 15 files |

Action taken:
- Installed `black`, `ruff`, and `mypy` into `backend/env`.
- Added Black config to `pyproject.toml`.
- Added Ruff config to `pyproject.toml` and ignored FastAPI/Black-incompatible rules: `B008`, `E501`, `UP042`, `UP046`.
- Added `pythonpath = ["."]` to pytest config.
- Added `black`, `ruff`, and `mypy` to `requirements-extra.txt`.
- Ran Black formatting across `app` and `tests`.
- Ran Ruff safe auto-fixes and manually fixed exception chaining, unused locals, and one import alias issue.

MyPy failure categories:
- Missing stubs for `jose`, `passlib.context`, and `celery`.
- Service methods named `list` are being interpreted as a type in return annotations like `-> list[...]`.
- A few router iterability errors cascade from those service return type issues.
- `tests/conftest.py` needs an `AsyncGenerator` return annotation for the async fixture.

Recommended next MyPy fixes:
- Install or configure stubs: `types-python-jose`, `types-passlib`; add a mypy override for Celery if no suitable stubs are used.
- Add `from __future__ import annotations` where needed, or use `builtins.list[...]` / `typing.Sequence[...]` where method names shadow `list`.
- Fix the `grades/service.py` `Result` variable reassignment typing issue.
- Annotate async generator fixtures as `AsyncGenerator[...]`.

---

## Requirement Coverage Snapshot

| Area | Current State | Gap |
|---|---|---|
| MOD-1 Authentication | Partially implemented | Role code mismatch, token leakage, incomplete audit, no tests |
| MOD-2 User Management | Partially implemented | Lifecycle transitions need state rules and tests |
| MOD-3 Academic Structure | Partially implemented | Public read APIs missing, role guards mismatch |
| MOD-4 Course Management | Partially implemented | Registration validation needs stronger tests and transaction handling |
| MOD-5 Student Lifecycle | Partially implemented | Admissions portal workflow mostly missing |
| MOD-6 Finance & Fees | Partially implemented | Ledger/idempotency/transaction integrity missing |
| MOD-7 Communication | Partially implemented | No event-driven notification triggers; email logs not integrated |
| MOD-8 Administration | Minimal implementation | Audit/reporting/config governance incomplete |

---

## Suggested Implementation Order

1. Fix migrations and seed data first.
2. Normalize role codes and RBAC guards.
3. Fix test configuration and add auth/RBAC smoke tests.
4. Create dedicated `admissions` module for MOD-5 planning.
5. Implement admissions entities and state machine.
6. Harden enrollment transaction handling.
7. Harden finance ledger/payment flow.
8. Correct grade and standing calculations.
9. Add audit coverage across high-risk modules.
10. Update README and dependency management.

---

## Concrete Next Steps Before MOD-5 Work

1. Replace the empty Alembic migration with a real migration generated from the 36 SQLAlchemy tables.
2. Seed canonical role codes and update all `require_roles(...)` calls.
3. Add `pythonpath = ["."]` to pytest config.
4. Create `docs/srs-mod-5.md` focused on Admission & Student Enrollment Portal.
5. Create `app/modules/admissions/` instead of expanding applicant workflows inside `students`.
6. Add tests for:
   - registration/login
   - role guard access
   - applicant creation
   - application status transition
   - applicant conversion to student

---

## Overall Assessment

The backend is a useful early implementation foundation, but it should not be treated as implementation-complete for the SRS. The strongest part is the broad SQLAlchemy data model coverage. The weakest parts are migration delivery, role consistency, tests, and the lack of a dedicated admissions workflow module.

The best path is to stabilize infrastructure first, then implement MOD-5 admissions deliberately from its own SRS rather than continuing to spread admissions behavior across `students`, `finance`, and `communication`.
