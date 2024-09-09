# Stage 1: Builder stage
FROM python:3.9-slim AS builder

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies and Python dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc default-libmysqlclient-dev pkg-config && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt


# Stage 2: Runner stage
FROM python:3.9-slim AS runner

# Set working directory
WORKDIR /app

# Create a non-root user
RUN useradd -m django

# Install minimal system dependencies (only libmysqlclient)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Switch to the non-root user
USER django

# Copy the wheels and install Python dependencies
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache /wheels/*

# Copy the Django project files with correct ownership
COPY --chown=django:django ./django/. /app/

# Expose the application port
EXPOSE 8000

# Run migrations and start Django development server
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
