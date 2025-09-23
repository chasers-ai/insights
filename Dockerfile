# Use the official Superset image as a base
FROM apache/superset:latest

# Switch to root to install dependencies
USER root

# Install database drivers and other OS packages if needed
# For example, to add Google BigQuery drivers:
# RUN pip install pybigquery

# Copy your custom configuration and requirements
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY superset_config.py /app/pythonpath/

# Switch back to the non-privileged superset user
USER superset
