# Base image for building the wheels
FROM python:3.9-slim as builder

WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       pkg-config \
       libpq-dev \
       libmariadb-dev-compat \
       libmariadb-dev \
       python3-dev \
    && apt-get clean

# Verify installation of pkg-config and libraries
RUN pkg-config --version \
    && pkg-config --exists mysqlclient || echo "mysqlclient not found by pkg-config" \
    && pkg-config --exists mariadb || echo "mariadb not found by pkg-config" \
    && pkg-config --exists libmariadb || echo "libmariadb not found by pkg-config"

# Install Python dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# Final image
FROM python:3.9-slim

WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       libpq-dev \
       libmariadb3 \
    && apt-get clean

# Copy the wheels and install them
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache /wheels/*

# Copy the Django project into the container
COPY ./django/. /app/

# Expose the necessary port
EXPOSE 8010

# Run the
