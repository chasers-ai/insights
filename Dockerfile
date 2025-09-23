# Use the official Superset image as a base
FROM apache/superset:latest

# Switch to root
USER root

# Copy your custom configuration
COPY superset_config.py /app/pythonpath/

# Switch back to the superset user
USER superset
