PYTHON ?= python
HOST ?= 0.0.0.0
PORT ?= 8000

.PHONY: run dev format lint test seed seed-demo seed-all alembic-upgrade alembic-revision

run:
	uvicorn app.main:app --host $(HOST) --port $(PORT)

test:
	pytest -q

seed:
	$(PYTHON) -m app.db.seed

seed-demo:
	$(PYTHON) -m app.db.seed_demo

# Essentials + full demo dataset in one go.
seed-all:
	$(PYTHON) -m app.db.seed && $(PYTHON) -m app.db.seed_demo

dev:
	uvicorn app.main:app --reload --host $(HOST) --port $(PORT)

format:
	ruff format app

lint:
	ruff check app

alembic-upgrade:
	alembic upgrade head

alembic-revision:
	alembic revision --autogenerate -m "init"
