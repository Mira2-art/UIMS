from redis.asyncio import Redis

from app.core.config import settings

redis_client: Redis | None = None


async def init_redis() -> None:
    global redis_client
    if not settings.redis_enabled:
        return

    redis_client = Redis.from_url(settings.redis_url, decode_responses=True)
    await redis_client.ping()


async def close_redis() -> None:
    global redis_client
    if redis_client is not None:
        await redis_client.aclose()
        redis_client = None


def get_redis() -> Redis:
    if redis_client is None:
        raise RuntimeError(
            "Redis client is not initialized. Set REDIS_ENABLED=true and restart app."
        )
    return redis_client
