# Use a specific, stable version of the official Superset image
FROM apache/superset:4.0.1

# Switch to root to perform operations
USER root

# Copy your custom configuration
COPY superset_config.py /app/pythonpath/

# Change the ownership of the config file to the superset user
RUN chown superset:superset /app/pythonpath/superset_config.py

# Switch back to the non-privileged superset user
USER superset
