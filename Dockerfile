# Start from a clean, official Python image
FROM python:3.9-slim-bullseye

# Set environment variables
ENV SUPERSET_VERSION=5.0.0
ENV FLASK_APP=superset
ENV SUPERSET_HOME=/var/lib/superset
ENV SUPERSET_CONFIG_PATH=/etc/superset/superset_config.py

# Create a non-privileged user
RUN groupadd --gid 1000 superset && \
    useradd --uid 1000 --gid superset --home-dir ${SUPERSET_HOME} --create-home superset

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install a compatible version of marshmallow FIRST, then Superset
RUN pip install \
    apache-superset==${SUPERSET_VERSION} \
    psycopg2

# Copy your custom configuration
RUN mkdir -p /etc/superset
COPY superset_config.py ${SUPERSET_CONFIG_PATH}
RUN chown superset:superset ${SUPERSET_CONFIG_PATH}

# Switch to the non-privileged user
USER superset
WORKDIR ${SUPERSET_HOME}

# Expose the port Cloud Run will assign
EXPOSE 8080

# Define the command to run Superset using the PORT variable provided by Cloud Run
CMD exec gunicorn --bind "0.0.0.0:${PORT}" --workers 2 --worker-class gthread --threads 20 --timeout 60 "superset.app:create_app()"
