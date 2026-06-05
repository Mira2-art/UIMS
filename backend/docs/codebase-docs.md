# Codebase Documentation

## Project Purpose

This backend is an async FastAPI scaffold for a school system. It is structured for clear separation of concerns, scalability, and easier feature iteration as your SRS evolves.

## High-Level Structure

- `app/main.py`
- `app/api/`
- `app/core/`
- `app/db/`
- `app/modules/`
- `alembic/`
- `tests/`
- `.env.example`
- `pyproject.toml`

## Why Each Core Area Exists

### `app/main.py`

Single FastAPI application entrypoint.

Why:
- Keeps bootstrapping in one place.
- Wires lifespan events (startup/shutdown).
- Applies global middleware (CORS).
- Includes versioned API router.

### `app/api/`

Contains HTTP interface wiring (routes + dependencies), including API versioning in `api/v1`.

Why:
- Keeps transport layer separate from business logic.
- Lets you evolve API versions without breaking old clients.

### `app/core/`

Cross-cutting concerns: configuration, logging, security helpers, Redis setup.

Why:
- Prevents config/security logic from leaking into modules.
- Makes environment-driven behavior centralized and predictable.

### `app/db/`

Async SQLAlchemy engine/session, base models/mixins, shared repository patterns.

Why:
- Standardizes database access patterns.
- Makes async PostgreSQL usage consistent across modules.
- Reduces repetitive CRUD boilerplate.

### `app/modules/`

Domain modules (`auth`, `users`, `students`, `teachers`, `courses`, `enrollments`, `grades`) each split into:
- `models.py`
- `schemas.py`
- `repository.py`
- `service.py`
- `router.py`

Why:
- Strong separation of concerns inside each module.
- Easier ownership and testing per feature.
- Business logic stays in services, not routers.

### `alembic/`

Schema migration tooling and migration history.

Why:
- Safe schema evolution across environments.
- Reproducible DB changes instead of manual SQL drift.

### `tests/`

Async test setup and endpoint-level tests.

Why:
- Establishes quality baseline from day one.
- Prevents regressions as SRS-driven features are added.

## Runtime Components Installed/Configured

### FastAPI + Uvicorn

Used to expose async HTTP APIs with automatic OpenAPI docs.

### SQLAlchemy Async + `asyncpg`

Used for non-blocking PostgreSQL access with modern ORM patterns.

### Redis (async client)

Configured for optional caching/session/rate-limit support.

Why optional now:
- `REDIS_ENABLED=false` by default to avoid local startup failures if Redis is not running yet.

### Alembic

Used for database migrations and schema version control.

## Tooling Clarification: Linting vs Formatting vs Testing

### Ruff

Used for linting in this scaffold (and can also format code if desired).

### Pytest

Used for test execution.

### Black

Black is a **formatter only**.

Why use Black:
- Enforces one consistent Python style automatically.
- Reduces style arguments in PRs.
- Keeps diffs cleaner and easier to review.
- Works well with linters (Ruff/Flake8) and tests (Pytest).

Important:
- Black does **not** lint code quality rules.
- Black does **not** run tests.

## Current Config Notes

- Ruff is currently configured in `pyproject.toml`.
- Pytest is configured in `pyproject.toml` with async support.
- CORS is set to allow all origins (`["*"]`) for now.
- PostgreSQL and Redis URLs are environment-driven via `.env`.

## Next Iteration (When SRS Arrives)

Planned hardening areas:
- Replace permissive CORS (`*`) with environment-specific origins.
- Add full auth flow (password verification, refresh tokens, role checks).
- Add DB constraints/relationships based on exact SRS domain rules.
- Expand tests to service/repository layers and failure-path coverage.
