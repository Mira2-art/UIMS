PYTHON ?= python

.PHONY: run dev format lint alembic-upgrade alembic-revision

run:
	uvicorn app.main:app --host 0.0.0.0 --port 8000

dev:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

format:
	ruff format app

lint:
	ruff check app

alembic-upgrade:
	alembic upgrade head

alembic-revision:
	alembic revision --autogenerate -m "init"
