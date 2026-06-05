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

## Migrations

```bash
cd backend
alembic revision --autogenerate -m "init"
alembic upgrade head
```
