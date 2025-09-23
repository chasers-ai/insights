# Use the official Superset image as a base
FROM apache/superset:latest

# Switch to root to install dependencies
USER root

# Add this block to install system dependencies for psycopg2
RUN apt-get update && apt-get install -y \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install any Python packages from pip
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Copy your custom configuration
COPY superset_config.py /app/pythonpath/

# Switch back to the superset user
USER superset
