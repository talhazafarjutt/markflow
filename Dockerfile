# Use an official Python image based on Debian Bullseye (includes SQLite 3.34+)
FROM python:3.10-slim-bullseye

# Prevent Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DJANGO_SETTINGS_MODULE=markflow.settings

# Install system dependencies, including tools to build SQLite
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       libpq-dev \
       sqlite3 \
       libsqlite3-dev \
       wget \
    && rm -rf /var/lib/apt/lists/*

# Install a newer SQLite version from source
RUN wget https://www.sqlite.org/2023/sqlite-autoconf-3410100.tar.gz && \
    tar xvf sqlite-autoconf-3410100.tar.gz && \
    cd sqlite-autoconf-3410100 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf sqlite-autoconf-3410100 sqlite-autoconf-3410100.tar.gz

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create and grant permissions to a non-root user
RUN useradd --create-home django_user \
    && chown -R django_user:django_user /app

# Switch to non-root user
USER django_user

# Ensure static root directory exists and collect static files
RUN mkdir -p /app/staticfiles \
    && python manage.py collectstatic --noinput

# Expose port Django runs on
EXPOSE 8000

# Launch the application with Gunicorn, using the newer SQLite library
CMD ["sh", "-c", "LD_LIBRARY_PATH=/usr/local/lib gunicorn --bind 0.0.0.0:8000 markflow.wsgi:application"]
