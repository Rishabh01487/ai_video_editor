#!/bin/bash
# Entrypoint script to start backend and frontend services

# Get the PORT from environment, default to 8000
PORT=${PORT:-8000}

# Start Nginx in the background
echo "Starting Nginx on port 80..."
nginx -g 'daemon off;' &
NGINX_PID=$!

# Wait for Nginx to start
sleep 2

# Start backend API server
echo "Starting backend API on port $PORT..."
cd /app/backend && python -m uvicorn app.main:app --host 0.0.0.0 --port "$PORT" &
UVICORN_PID=$!

# Wait for both processes
wait $NGINX_PID $UVICORN_PID

# Exit with the status of the last command
exit $?
