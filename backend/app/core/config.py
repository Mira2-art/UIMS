from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "School Backend"
    environment: str = "development"
    api_v1_prefix: str = "/api/v1"
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/school_db"
    sql_echo: bool = False
    auto_create_tables: bool = False
    secret_key: str = "change-me"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7
    cors_origins: list[str] = ["*"]

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
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
