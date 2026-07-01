# Stage 1: Build dependencies
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runner image
FROM python:3.12-slim AS runner

WORKDIR /app

# Install runtime dependencies (libpq5 is needed for postgres, curl for healthchecks)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder stage
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

# Copy application files
COPY alembic.ini .
COPY alembic/ ./alembic/
COPY app/ ./app/
COPY templates/ ./templates/
COPY static/ ./static/
COPY Makefile .
COPY pyproject.toml .

# Expose default API port
EXPOSE 8000

# Create and use non-root user for security
RUN useradd -u 10001 -m appuser && \
    chown -R appuser:appuser /app
USER appuser

# Container-level health probe (the load balancer / orchestrator can use this).
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -fsS http://localhost:8000/api/v1/health || exit 1

# Default CMD — a single worker. In production, override with multiple workers,
# e.g. `--workers 4` (see docker-compose.yml / WEB_CONCURRENCY). `--proxy-headers`
# makes it honour X-Forwarded-* when behind a load balancer.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers", "--forwarded-allow-ips", "*"]
