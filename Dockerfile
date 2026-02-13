# Multi-service Dockerfile for AI Video Editor Platform
# Railway will use this to build and deploy
# This image orchestrates both backend and frontend
# Force rebuild (v2)

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    git \
    nodejs \
    npm \
    curl \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy backend files
COPY backend/requirements.txt ./backend_requirements.txt
RUN pip install --no-cache-dir -r ./backend_requirements.txt

# Download YOLOv8 model
RUN python -c "from ultralytics import YOLO; YOLO('yolov8n.pt')"

# Copy backend code
COPY backend ./backend

# Setup frontend
COPY frontend ./frontend
WORKDIR /app/frontend
ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL
RUN npm install --legacy-peer-deps
RUN npm run build

# Return to app root
WORKDIR /app

# Copy Nginx configuration
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create temp directory
RUN mkdir -p /tmp/ai_video_editor

# Expose ports
EXPOSE 8000 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start both Nginx (frontend) and backend API server
ENTRYPOINT ["/entrypoint.sh"]
