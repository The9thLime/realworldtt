# Base image
FROM python:3.9-slim AS builder

WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies and Python dependencies
RUN apt-get update && \
    apt-get install -y gcc default-libmysqlclient-dev pkg-config && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

FROM python:3.9-slim AS runner

WORKDIR /app

# Create a non-root user
RUN useradd -m django

# Install system dependencies (no need for gcc here, only mysqlclient dev lib)
RUN apt-get update && \
    apt-get install -y --no-install-recommends default-libmysqlclient-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Switch to the non-root user
USER django

# Copy the wheels and requirements
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache /wheels/*

# Copy the Django project into the container
COPY --chown=django:django ./django/. /app/

EXPOSE 8000

# Use the non-root user for running the commands
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
