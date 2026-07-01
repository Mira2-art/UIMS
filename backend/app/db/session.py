import logging
from collections.abc import AsyncGenerator
from urllib.parse import urlsplit

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings
from app.db.base import Base
from app.db.models import import_models

logger = logging.getLogger("app.db")


def _postgres_reachable(url: str, timeout: float = 1.5) -> bool:
    """Cheap TCP probe of the Postgres host:port (no driver round-trip)."""
    import socket

    parts = urlsplit(url)
    host = parts.hostname or "localhost"
    port = parts.port or 5432
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def _resolve_database_url() -> str:
    """Use the configured DB; if it's Postgres and unreachable, fall back to
    async SQLite so the app still boots locally."""
    url = settings.database_url
    if url.startswith("sqlite"):
        return url  # already SQLite — nothing to probe
    if not settings.db_fallback_enabled:
        return url
    if _postgres_reachable(url):
        return url
    logger.warning(
        "PostgreSQL unreachable (%s) — falling back to async SQLite at %s",
        urlsplit(url).hostname,
        settings.sqlite_fallback_url,
    )
    return settings.sqlite_fallback_url


DATABASE_URL = _resolve_database_url()
IS_SQLITE = DATABASE_URL.startswith("sqlite")

# SQLite needs check_same_thread off; pool_pre_ping is a Postgres nicety.
_engine_kwargs: dict = {"echo": settings.sql_echo}
if IS_SQLITE:
    _engine_kwargs["connect_args"] = {"check_same_thread": False}
else:
    _engine_kwargs["pool_pre_ping"] = True

engine = create_async_engine(DATABASE_URL, **_engine_kwargs)
SessionLocal = async_sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with SessionLocal() as session:
        yield session


async def init_db() -> None:
    import_models()
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def close_db() -> None:
    await engine.dispose()
