# Stage 1: Build environment
FROM python:3.9-slim AS builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc

# Install Python dependencies
COPY requirements.txt /app/
RUN python -m venv /app/venv \
    && . /app/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r requirements.txt

# Stage 2: Runtime environment
FROM python:3.9-slim AS runtime

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /app

# Install curl
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl
# Copy the virtual environment from the builder stage
COPY --from=builder /app/venv /app/venv

# Copy the Django project into the container
COPY . /app/

CMD ["sh", "-c", "/app/venv/bin/python manage.py migrate && /app/venv/bin/python manage.py runserver 0.0.0.0"]
