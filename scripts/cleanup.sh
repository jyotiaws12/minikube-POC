#!/bin/bash
# =============================================================
# Cleanup Script - Remove all POC resources
# =============================================================
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "============================================="
echo "  Cleanup - Removing all POC resources"
echo "============================================="

# Cleanup Kubernetes resources
echo ""
echo "[1/3] Removing Kubernetes resources..."
kubectl delete namespace poc-app --ignore-not-found=true 2>/dev/null || true
echo "Kubernetes resources removed."

# Cleanup Terraform resources
echo ""
echo "[2/3] Removing Terraform resources..."
if [ -d "${PROJECT_ROOT}/terraform/.terraform" ]; then
    cd "${PROJECT_ROOT}/terraform"
    terraform destroy -auto-approve 2>/dev/null || true
    rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tfplan
fi
echo "Terraform resources removed."

# Cleanup Docker resources
echo ""
echo "[3/3] Removing Docker resources..."
docker stop poc-app-container 2>/dev/null || true
docker rm poc-app-container 2>/dev/null || true
docker rmi poc-app:latest 2>/dev/null || true
echo "Docker resources removed."

echo ""
echo "============================================="
echo "  Cleanup complete!"
echo "============================================="
