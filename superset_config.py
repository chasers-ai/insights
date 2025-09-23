import os

# Get the database URI and secret key from environment variables
# Cloud Run will provide these from Secret Manager
SQLALCHEMY_DATABASE_URI = os.environ.get("SUPERSET_DB_URI")
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY")

# You can enable feature flags here if you wish
# For example, to enable template processing in SQL Lab:
FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
}
