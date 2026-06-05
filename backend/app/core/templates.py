from __future__ import annotations

from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, select_autoescape

from app.core.config import settings


def _templates_root() -> Path:
    root = Path(settings.templates_dir)
    if not root.is_absolute():
        root = Path.cwd() / root
    return root.resolve()


_env = Environment(
    loader=FileSystemLoader(_templates_root()),
    autoescape=select_autoescape(("html", "xml")),
    trim_blocks=True,
    lstrip_blocks=True,
)


def render_template(template_name: str, **context: Any) -> str:
    return _env.get_template(template_name).render(**context)
