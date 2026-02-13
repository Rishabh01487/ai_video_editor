# Railway.app deployment Procfile

# For Backend
web: cd backend && uvicorn app.main:app --host 0.0.0.0 --port $PORT

# For Worker (optional)
worker: cd backend && celery -A workers.celery_app worker --loglevel=info
