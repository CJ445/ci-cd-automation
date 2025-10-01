# Multi-stage Docker build for optimal image size and security

# Stage 1: Builder stage
FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime stage
FROM python:3.11-slim

# Set metadata labels
LABEL maintainer="devops@example.com"
LABEL description="CI/CD Demo Application"
LABEL version="1.0.0"

# Create non-root user for security
RUN useradd -m -u 1000 appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

# Set working directory
WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /home/appuser/.local

# Copy application code
COPY --chown=appuser:appuser app.py .

# Switch to non-root user
USER appuser

# Add local bin to PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=5000
ENV ENVIRONMENT=production

# Expose application port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

# Run application with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "60", "app:app"]
