#!/bin/bash
# =============================================================
# Terraform Deployment Script
# =============================================================
# This script deploys the app using Terraform instead of kubectl.
# Same result, but with state management and drift detection!
# =============================================================
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="${PROJECT_ROOT}/terraform"
IMAGE_NAME="poc-app"
IMAGE_TAG="latest"

echo "============================================="
echo "  Terraform Deployment"
echo "============================================="

# Step 1: Check Minikube
echo ""
echo "[1/5] Checking Minikube status..."
if ! minikube status &> /dev/null; then
    echo "Minikube is not running. Starting..."
    minikube start --driver=docker
fi

# Step 2: Build image inside Minikube
echo ""
echo "[2/5] Building image in Minikube's Docker daemon..."
eval $(minikube docker-env)
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f "${PROJECT_ROOT}/docker/Dockerfile" "${PROJECT_ROOT}"

# Step 3: Terraform init
echo ""
echo "[3/5] Initializing Terraform..."
cd "${TF_DIR}"
terraform init

# Step 4: Terraform plan
echo ""
echo "[4/5] Planning changes..."
terraform plan -out=tfplan

# Step 5: Terraform apply
echo ""
echo "[5/5] Applying changes..."
terraform apply tfplan

echo ""
echo "============================================="
echo "  Terraform deployment successful!"
echo ""
echo "  View state:    cd terraform && terraform show"
echo "  View outputs:  cd terraform && terraform output"
echo "  Destroy:       cd terraform && terraform destroy"
echo ""
echo "  Access the app:"
echo "    minikube service poc-app-nodeport -n poc-app-tf"
echo "============================================="
