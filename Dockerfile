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
    && apt-get clean

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

# Run the Django application
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8010"]
