# Use a specific, stable version of the official Superset image
FROM apache/superset:4.0.1

# Switch to root
USER root

# Copy your custom configuration
COPY superset_config.py /app/pythonpath/

# Switch back to the superset user
USER superset
