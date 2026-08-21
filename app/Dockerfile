# Multi-stage production Dockerfile for AegisMind SRE Control Plane Engine

# Stage 1: Build & dependency installation stage
FROM python:3.11-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Minimal runtime stage
FROM python:3.11-slim AS runner

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root system user for security best practices
RUN groupadd -g 10001 aegisgroup && \
    useradd -u 10001 -g aegisgroup -s /bin/sh -m aegisuser

# Copy installed dependencies from builder
COPY --from=builder /root/.local /home/aegisuser/.local
COPY src/ /app/src/

ENV PATH=/home/aegisuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

RUN chown -R aegisuser:aegisgroup /app

USER aegisuser

EXPOSE 8000

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "-m", "uvicorn", "src.api.server:app", "--host", "0.0.0.0", "--port", "8000"]
