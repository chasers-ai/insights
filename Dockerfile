# =================================================================
# STAGE 1: The "Builder" - where we install everything
# =================================================================
FROM python:3.10-slim-bullseye AS builder

# Set environment variables
ENV SUPERSET_VERSION=5.0.0
ENV FLASK_APP=superset
ENV SUPERSET_HOME=/var/lib/superset
ENV SUPERSET_CONFIG_PATH=/etc/superset/superset_config.py

# Install system dependencies needed ONLY for building
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Superset and drivers into a virtual environment
# This makes it easy to copy to the next stage
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip && pip install \
    marshmallow==3.21.1 \
    apache-superset==${SUPERSET_VERSION} \
    psycopg2 \
    pybigquery \
    gunicorn

# =================================================================
# STAGE 2: The "Final" Image - slim and secure
# =================================================================
FROM python:3.10-slim-bullseye

# Set environment variables again for the final stage
ENV SUPERSET_VERSION=5.0.0
ENV FLASK_APP=superset
ENV SUPERSET_HOME=/var/lib/superset
ENV SUPERSET_CONFIG_PATH=/etc/superset/superset_config.py
ENV PATH="/opt/venv/bin:$PATH"

# Create a non-privileged user (same as before)
RUN groupadd --gid 1000 superset && \
    useradd --uid 1000 --gid superset --home-dir ${SUPERSET_HOME} --create-home superset

# Copy the installed Python packages from the "builder" stage
COPY --from=builder /opt/venv /opt/venv

# Copy your custom configuration (same as before)
RUN mkdir -p /etc/superset
COPY superset_config.py ${SUPERSET_CONFIG_PATH}

# --- EFFICIENT BRANDING CHANGES ---
# 1. Copy all assets in a single, efficient layer
COPY ./assets/loading.gif /opt/venv/lib/python3.10/site-packages/superset/static/assets/images/loading.gif
COPY ./assets/chasers-logo.png /opt/venv/lib/python3.10/site-packages/superset/static/assets/images/superset-logo-horiz.png
COPY ./assets/loading.gif /opt/venv/lib/python3.10/site-packages/superset/static/assets/loading.cff8a5da.gif
COPY ./assets/kraken-logo.png /opt/venv/lib/python3.10/site-packages/superset/static/assets/kraken-logo.png
COPY ./assets/mediacampaign-logo.png /opt/venv/lib/python3.10/site-packages/superset/static/assets/mediacampaign-logo.png
COPY ./assets/trailfinders-logo.jpeg /opt/venv/lib/python3.10/site-packages/superset/static/assets/trailfinders-logo.jpeg
COPY ./assets/chasers-flavicon.png /opt/venv/lib/python3.10/site-packages/superset/static/assets/images/favicon.png

# 2. WARNING: This line is fragile and will break on Superset updates
RUN sed -i 's/"Waiting on %s"/"Loading..."/g' /opt/venv/lib/python3.10/site-packages/superset/static/assets/b5a84132091404d9e284.chunk.js

# 3. Set ownership for all copied files and configs at once
RUN chown -R superset:superset ${SUPERSET_CONFIG_PATH} ${SUPERSET_HOME} /opt/venv/lib/python3.10/site-packages/superset/static/assets

# Switch to the non-privileged user
USER superset
WORKDIR ${SUPERSET_HOME}

# Expose the port Cloud Run will assign
EXPOSE 8080

# Define the command to run Superset
CMD exec gunicorn --bind "0.0.0.0:${PORT}" --workers 2 --worker-class gthread --threads 20 --timeout 60 "superset.app:create_app()"
