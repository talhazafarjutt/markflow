# Use an official lightweight Python image.
FROM python:3.10-slim-buster

# Prevents Python from writing pyc files to disc and buffers stdout/stderr.
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DJANGO_SETTINGS_MODULE=markflow.settings

# Install system dependencies and create a virtual environment.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Create a non-root user and adjust permissions
RUN useradd --create-home django_user \
    && chown -R django_user:django_user /app
USER django_user

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose application port
EXPOSE 8000

# Default command: start Gunicorn server
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "markflow.wsgi:application"]
