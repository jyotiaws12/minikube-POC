#!/bin/bash
# =============================================================
# Docker Build & Run Script
# =============================================================
# This script builds the Docker image and runs it locally.
# Use this to test the container before deploying to Kubernetes.
# =============================================================
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE_NAME="poc-app"
IMAGE_TAG="latest"
CONTAINER_NAME="poc-app-container"

echo "============================================="
echo "  Docker Build & Run"
echo "============================================="

# Step 1: Build the image
echo ""
echo "[1/3] Building Docker image..."
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f "${PROJECT_ROOT}/docker/Dockerfile" "${PROJECT_ROOT}"
echo "Image built: ${IMAGE_NAME}:${IMAGE_TAG}"

# Step 2: Stop and remove existing container (if any)
echo ""
echo "[2/3] Cleaning up old container..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

# Step 3: Run the container
echo ""
echo "[3/3] Starting container..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p 5000:5000 \
    -e APP_NAME="K8s-Docker-Terraform POC" \
    -e ENVIRONMENT="docker-local" \
    "${IMAGE_NAME}:${IMAGE_TAG}"

echo ""
echo "============================================="
echo "  Container is running!"
echo "  Open: http://localhost:5000"
echo "  Health: http://localhost:5000/health"
echo "  Info: http://localhost:5000/info"
echo ""
echo "  Useful commands:"
echo "    docker logs ${CONTAINER_NAME}"
echo "    docker exec -it ${CONTAINER_NAME} /bin/bash"
echo "    docker stop ${CONTAINER_NAME}"
echo "============================================="
