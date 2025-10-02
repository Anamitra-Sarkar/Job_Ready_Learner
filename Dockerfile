# Job Ready Platform - Backend Dockerfile
# Multi-stage build for optimized production image

FROM swipl:latest as base

# Metadata
LABEL maintainer="Anamitra Sarkar"
LABEL description="Job Ready Platform - AI-powered learning backend"
LABEL version="1.0.0"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create app user (security best practice)
RUN groupadd -r appuser && \
    useradd -r -g appuser -s /bin/false appuser

# Set working directory
WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/data /app/logs && \
    chown -R appuser:appuser /app

# Copy application files
COPY --chown=appuser:appuser main.pl /app/

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8080/api/health || exit 1

# Environment variables with defaults
ENV PROLOG_STACK_LIMIT=4g \
    LOG_LEVEL=info \
    RATE_LIMIT_ENABLED=true \
    MAX_REQUESTS_PER_MINUTE=60

# Start the server
CMD ["swipl", "-s", "main.pl"]
