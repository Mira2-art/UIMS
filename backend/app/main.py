from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.v1.api import api_router
from app.core.config import settings
from app.core.logging import configure_logging
from app.core.redis import close_redis, init_redis
from app.db.session import close_db, init_db


@asynccontextmanager
async def lifespan(_: FastAPI):
    configure_logging()
    await init_redis()
    # Create tables when explicitly enabled, or on the SQLite fallback (no Alembic).
    from app.db.session import IS_SQLITE

    if settings.auto_create_tables or IS_SQLITE:
        await init_db()

    # Seed on startup so a fresh deployment (Docker or bare server) comes up with
    # a working dataset. Both steps are idempotent — safe to run on every boot.
    if settings.seed_on_startup:
        from app.db.seed import seed_all

        await seed_all()
    if settings.seed_demo_on_startup:
        from app.db.seed_demo import seed_demo

        await seed_demo()
    yield
    await close_redis()
    await close_db()


app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    openapi_url=f"{settings.api_v1_prefix}/openapi.json",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

static_dir = Path(settings.static_dir)
static_dir.mkdir(parents=True, exist_ok=True)
app.mount(settings.static_url_path, StaticFiles(directory=static_dir), name="static")

app.include_router(api_router, prefix=settings.api_v1_prefix)
