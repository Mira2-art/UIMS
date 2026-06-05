from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession


async def sample_db_test(session: AsyncSession, endpoint: str) -> dict[str, str]:
    result = await session.execute(text("SELECT 'sample-db-test' AS message"))
    message = result.scalar_one()
    print(f"[sample-db-test] endpoint={endpoint}")
    return {"message": message, "endpoint": endpoint}
