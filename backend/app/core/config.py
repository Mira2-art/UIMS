from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "School Backend"
    environment: str = "development"
    api_v1_prefix: str = "/api/v1"
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/school_db"
    # Async SQLite fallback, used automatically when PostgreSQL is unreachable
    # (unless database_url is already a sqlite URL). Set db_fallback_enabled=False
    # to require PostgreSQL.
    sqlite_fallback_url: str = "sqlite+aiosqlite:///./trustech.db"
    db_fallback_enabled: bool = True
    sql_echo: bool = False
    auto_create_tables: bool = False
    secret_key: str = "change-me"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7
    cors_origins: list[str] = ["*"]

    # Seeding on startup. `seed_on_startup` inserts the essentials (roles, the
    # shared client app, current semesters, bootstrap admin) — safe/idempotent.
    # `seed_demo_on_startup` also loads the rich showcase dataset (students,
    # courses, grades, finance, attendance, announcements, notifications).
    seed_on_startup: bool = True
    seed_demo_on_startup: bool = False

    # Static files / uploads
    static_dir: str = "static"
    static_url_path: str = "/static"
    max_upload_size_mb: int = 10

    # Templates
    templates_dir: str = "templates"

    # Redis
    redis_enabled: bool = False
    redis_url: str = "redis://localhost:6379/0"

    # Celery
    celery_broker_url: str = "redis://localhost:6379/1"
    celery_result_backend: str = "redis://localhost:6379/2"

    # SMTP / Gmail
    smtp_host: str = "smtp.gmail.com"
    smtp_port: int = 587
    gmail_from: str = "noreply@example.com"
    gmail_app_password: str = "change-me"
    email_enabled: bool = False

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        # Ignore unknown keys (e.g. SEED_CLIENT_ID / SEED_ADMIN_* used only by the
        # seed scripts) so they can live in the same .env without breaking startup.
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
