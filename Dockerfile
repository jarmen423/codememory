# Agentic Memory - Production Dockerfile
# Multi-stage build for smaller image size
# Build: docker build -t codememory .
# Run:   docker run --rm -v $(pwd):/workspace codememory index /workspace

# Stage 1: Builder
FROM python:3.12-slim as builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends     gcc     && rm -rf /var/lib/apt/lists/*

# Copy and install package
COPY pyproject.toml requirements.txt ./
COPY src/ ./src/
RUN pip install --user --no-cache-dir -e .

# Stage 2: Runtime
FROM python:3.12-slim

# Create non-root user
RUN groupadd -r codememory && useradd -r -g codememory codememory

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /root/.local /home/codememory/.local
ENV PATH=/home/codememory/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app/src

# Copy source (for development / editable installs)
COPY --chown=codememory:codememory src/ ./src/
COPY --chown=codememory:codememory pyproject.toml ./

USER codememory

# Default command
ENTRYPOINT ["python", "-m", "codememory.cli"]
CMD ["--help"]

# Healthcheck (optional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3     CMD python -m codememory.cli status || exit 1
