# Trustech Backend — Run & Tooling Guide

Everything you need to set up, run, migrate, seed, lint, format, and test the
FastAPI backend. Run all commands from the `backend/` directory.

## TL;DR (first run)

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt          # + requirements-extra.txt for dev tools
cp .env.example .env                      # then edit DATABASE_URL / SECRET_KEY
cd backend && alembic upgrade head && make seed && make test
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000  # http://10.216.91.251:8000/docs
```

## 1. Prerequisites

- **Python 3.12** (ruff/black target `py312`).
- **PostgreSQL** (async driver `asyncpg`) — create a DB, e.g. `school_db`.
- **Redis** (optional locally; required for Celery email tasks). Toggle with `REDIS_ENABLED`.

## 2. Setup

```bash
python -m venv .venv
source .venv/bin/activate                 # Windows: .venv\Scripts\activate
pip install -r requirements.txt           # runtime deps
pip install -r requirements-extra.txt     # dev tools: black, ruff, pytest
```

## 3. Environment

```bash
cp .env.example .env
```
Key vars (see `.env.example`):

| Var | Meaning |
|-----|---------|
| `DATABASE_URL` | `postgresql+asyncpg://user:pass@host:5432/school_db` |
| `SECRET_KEY` | JWT signing secret — **change it** |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | access-token lifetime |
| `AUTO_CREATE_TABLES` | `true` creates tables on startup (dev only; prefer Alembic) |
| `CORS_ORIGINS` | JSON list, e.g. `["*"]` |
| `REDIS_ENABLED` / `REDIS_URL` | enable Redis + connection |

## 4. Database migrations (Alembic, async)

```bash
alembic upgrade head                      # apply migrations   (make alembic-upgrade)
alembic revision --autogenerate -m "msg"  # new migration      (make alembic-revision)
alembic downgrade -1                       # roll back one
alembic current                            # show current revision
alembic history                            # list revisions
```

## 5. Seed data (roles, client apps, semesters, admin)

```bash
make seed                                  # or: python -m app.db.seed
```
Idempotent. Creates system roles (incl. `DEAN`/`REGISTRAR` for grading), the
mobile/web `client_id`s, the current academic year's two semesters (**October**
start), and a bootstrap admin `admin@trustech.cm` / `ChangeMe123!`
(override via `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD`).

### Demo dataset (rich, for showcase)

```bash
make seed-demo          # or: python -m app.db.seed_demo
```
Idempotent (skips if already seeded). Creates **2 faculties → 2 departments →
2 programmes** (Computer Science + Management), **4 semesters** (2024/2025 S1+S2,
2025/2026 S3 completed + S4 current), **6 courses/semester**, **7 lecturers** (+ a
Dean per faculty), and **10 students/programme**. Each student registers all
courses every semester; the 3 completed semesters carry published **CA (/30) +
EXAM (/70)** grades and the system auto-computes each semester's **GPA** + the
cumulative **CGPA** (4.0). All accounts use password `Password123!`
(e.g. `cs.student1@trustech.cm`).

## 6. Run the API

Bind to **`0.0.0.0`** (all interfaces) so phones on the same WiFi can reach it at
this machine's LAN IP. Don't bind a specific IP unless it's actually assigned to a
NIC — otherwise you get `Cannot assign requested address`.

```bash
python run.py                                              # 0.0.0.0:8000, reload (recommended)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000   # (make dev)
fastapi dev app/main.py --host 0.0.0.0 --port 8000         # fastapi CLI
```
- Find your LAN IP with `hostname -I` (currently **`10.216.91.251`**).
- Reachable from phones at `http://10.216.91.251:8000` — point the mobile apps'
  `ApiConfig.baseUrl` there. Swagger UI: `http://10.216.91.251:8000/docs`.
- The IP is dynamic (WiFi/DHCP); if it changes, update `ApiConfig.baseUrl`.

### Database & SQLite fallback

The app uses **PostgreSQL** (`DATABASE_URL`). If Postgres is **unreachable** at
startup it automatically falls back to an **async SQLite** file
(`sqlite+aiosqlite:///./trustech.db`) so it still boots — tables are created
automatically (no Alembic needed on SQLite), and `make seed` / `make seed-demo`
work against either backend. Set `DB_FALLBACK_ENABLED=false` to require Postgres,
or point `DATABASE_URL` at a `sqlite+aiosqlite://…` URL to use SQLite explicitly.

## 7. Background tasks (Celery + Redis)

Email (welcome, verification, password reset, grade-published, fee reminders)
runs via Celery. Start Redis, then a worker:

```bash
celery -A app.core.celery_app:celery_app worker -l info
```

## 8. Lint & format

```bash
ruff check app                            # lint              (make lint)
ruff check app --fix                      # lint + autofix
ruff format app                           # format (ruff)     (make format)
black app                                 # format (black, line-length 100)
```
Config in `pyproject.toml` — ruff rules `E,F,I,B,UP,N`, line length 100, target py312.

## 9. Tests

```bash
make test                                 # pytest -q
pytest                                     # all tests (testpaths = tests/, asyncio auto)
pytest tests/test_grades_scale.py -v       # one file
pytest -k grade                            # by keyword
```

## 10. Make targets (summary)

| Target | Command |
|--------|---------|
| `make run` | uvicorn (10.216.91.251:8000) |
| `make dev` | uvicorn --reload (10.216.91.251:8000) |
| `make seed-demo` | `python -m app.db.seed_demo` |
| `make seed` | `python -m app.db.seed` |
| `make test` | `pytest -q` |
| `make format` | `ruff format app` |
| `make lint` | `ruff check app` |
| `make alembic-upgrade` | `alembic upgrade head` |
| `make alembic-revision` | autogenerate revision |

## 11. Typical dev loop

```bash
source .venv/bin/activate
make alembic-upgrade && make seed         # DB ready
make dev                                  # run API
# in another shell:
ruff check app --fix && black app && make test
```
