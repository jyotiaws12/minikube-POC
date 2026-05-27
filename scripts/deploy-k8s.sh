#!/bin/bash
# =============================================================
# Kubernetes Deployment Script (using kubectl)
# =============================================================
# This script deploys the app to Minikube using kubectl.
# It builds the image inside Minikube's Docker daemon so
# Kubernetes can access it with imagePullPolicy: Never.
# =============================================================
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE_NAME="poc-app"
IMAGE_TAG="latest"

echo "============================================="
echo "  Kubernetes Deployment (kubectl)"
echo "============================================="

# Step 1: Check Minikube
echo ""
echo "[1/5] Checking Minikube status..."
if ! minikube status &> /dev/null; then
    echo "Minikube is not running. Starting..."
    minikube start --driver=docker
fi
echo "Minikube is running!"

# Step 2: Build image inside Minikube's Docker
echo ""
echo "[2/5] Building image in Minikube's Docker daemon..."
echo "  (This makes the image available to Kubernetes)"
eval $(minikube docker-env)
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f "${PROJECT_ROOT}/docker/Dockerfile" "${PROJECT_ROOT}"
echo "Image built inside Minikube!"

# Step 3: Enable required addons
echo ""
echo "[3/5] Enabling Minikube addons..."
minikube addons enable metrics-server 2>/dev/null || true
minikube addons enable ingress 2>/dev/null || true

# Step 4: Apply Kubernetes manifests (in order)
echo ""
echo "[4/5] Applying Kubernetes manifests..."
kubectl apply -f "${PROJECT_ROOT}/kubernetes/01-namespace.yaml"
kubectl apply -f "${PROJECT_ROOT}/kubernetes/02-configmap.yaml"
kubectl apply -f "${PROJECT_ROOT}/kubernetes/03-secret.yaml"
kubectl apply -f "${PROJECT_ROOT}/kubernetes/04-deployment.yaml"
kubectl apply -f "${PROJECT_ROOT}/kubernetes/05-service.yaml"
kubectl apply -f "${PROJECT_ROOT}/kubernetes/06-ingress.yaml"
kubectl apply -f "${PROJECT_ROOT}/kubernetes/07-hpa.yaml"
kubectl apply -f "${PROJECT_ROOT}/kubernetes/08-persistent-volume.yaml"

# Step 5: Wait for deployment
echo ""
echo "[5/5] Waiting for pods to be ready..."
kubectl wait --for=condition=available deployment/poc-app -n poc-app --timeout=120s

echo ""
echo "============================================="
echo "  Deployment successful!"
echo ""
echo "  View pods:     kubectl get pods -n poc-app"
echo "  View services: kubectl get svc -n poc-app"
echo "  View all:      kubectl get all -n poc-app"
echo ""
echo "  Access the app:"
echo "    minikube service poc-app-nodeport -n poc-app"
echo ""
echo "  Or use port-forward:"
echo "    kubectl port-forward svc/poc-app-clusterip 8080:80 -n poc-app"
echo "    Then open: http://localhost:8080"
echo "============================================="
