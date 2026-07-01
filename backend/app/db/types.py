"""Cross-dialect column types so the same models run on PostgreSQL and SQLite.

PostgreSQL uses its native UUID; every other dialect (e.g. SQLite) stores the
UUID as a 36-char string. Imported as `PGUUID` in the models so no model body
changes are needed.
"""

from __future__ import annotations

import uuid

from sqlalchemy.dialects.postgresql import UUID as _PGUUID
from sqlalchemy.types import CHAR, TypeDecorator


class GUID(TypeDecorator):
    """Platform-independent UUID: native `UUID` on PostgreSQL, `CHAR(36)` else."""

    impl = CHAR
    cache_ok = True

    def __init__(self, *args, as_uuid: bool = True, **kwargs) -> None:
        # Accept (and honour) the `as_uuid=` kwarg the models pass.
        self.as_uuid = as_uuid
        super().__init__()

    def load_dialect_impl(self, dialect):
        if dialect.name == "postgresql":
            return dialect.type_descriptor(_PGUUID(as_uuid=self.as_uuid))
        return dialect.type_descriptor(CHAR(36))

    def process_bind_param(self, value, dialect):
        if value is None:
            return value
        if dialect.name == "postgresql":
            return value  # asyncpg / native UUID handles str or UUID
        if isinstance(value, uuid.UUID):
            return str(value)
        return str(uuid.UUID(str(value)))

    def process_result_value(self, value, dialect):
        if value is None:
            return value
        if dialect.name == "postgresql":
            return value
        if self.as_uuid and not isinstance(value, uuid.UUID):
            return uuid.UUID(value)
        return value
