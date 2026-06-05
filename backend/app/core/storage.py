from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from uuid import uuid4

from fastapi import HTTPException, UploadFile, status

from app.core.config import settings

_SAFE_SEGMENT_RE = re.compile(r"[^a-zA-Z0-9._-]+")
_SAFE_DOC_TYPE_RE = re.compile(r"[^a-zA-Z0-9_-]+")
_CHUNK_SIZE = 1024 * 1024


@dataclass(frozen=True)
class StoredUpload:
    file_path: str
    file_name: str
    file_size: int
    mime_type: str | None


def _sanitize_filename(filename: str) -> str:
    cleaned = _SAFE_SEGMENT_RE.sub("_", Path(filename).name).strip("._")
    return cleaned or "upload"


def normalize_doc_type(doc_type: str) -> str:
    cleaned = _SAFE_DOC_TYPE_RE.sub("_", doc_type.strip().lower()).strip("_")
    if not cleaned:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Document type is required")
    return cleaned[:80]


def _static_root() -> Path:
    root = Path(settings.static_dir)
    if not root.is_absolute():
        root = Path.cwd() / root
    return root.resolve()


async def save_upload_file(
    upload: UploadFile,
    *,
    folder_parts: tuple[str, ...],
    doc_type: str,
) -> StoredUpload:
    if not upload.filename:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Uploaded file must have a filename")

    safe_doc_type = normalize_doc_type(doc_type)
    original_name = _sanitize_filename(upload.filename)
    original_path = Path(original_name)
    suffix = original_path.suffix.lower()
    stem = _sanitize_filename(original_path.stem)[:60]
    timestamp = datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    stored_name = f"{timestamp}_{uuid4().hex[:12]}_{stem}{suffix}"

    relative_dir = Path("uploads").joinpath(*folder_parts, safe_doc_type)
    absolute_dir = _static_root() / relative_dir
    absolute_dir.mkdir(parents=True, exist_ok=True)

    absolute_path = absolute_dir / stored_name
    max_size = settings.max_upload_size_mb * _CHUNK_SIZE
    total_size = 0

    with absolute_path.open("wb") as destination:
        while chunk := await upload.read(_CHUNK_SIZE):
            total_size += len(chunk)
            if total_size > max_size:
                destination.close()
                absolute_path.unlink(missing_ok=True)
                raise HTTPException(
                    status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                    f"File exceeds {settings.max_upload_size_mb}MB limit",
                )
            destination.write(chunk)

    relative_path = relative_dir / stored_name
    return StoredUpload(
        file_path=relative_path.as_posix(),
        file_name=stored_name,
        file_size=total_size,
        mime_type=upload.content_type,
    )
