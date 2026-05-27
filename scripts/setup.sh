#!/bin/bash
# =============================================================
# Setup Script - Verify all prerequisites are installed
# =============================================================
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================="
echo "  K8s-Docker-Terraform POC - Setup Check"
echo "============================================="
echo ""

check_command() {
    local cmd=$1
    local name=$2
    if command -v "$cmd" &> /dev/null; then
        local version
        version=$($cmd version --short 2>/dev/null || $cmd --version 2>/dev/null | head -1)
        echo -e "${GREEN}[OK]${NC} $name is installed: $version"
        return 0
    else
        echo -e "${RED}[MISSING]${NC} $name is not installed"
        return 1
    fi
}

MISSING=0

echo "Checking prerequisites..."
echo ""

# Docker
if ! check_command "docker" "Docker"; then
    echo "  -> Install Docker Desktop: https://www.docker.com/products/docker-desktop"
    MISSING=1
fi

# kubectl
if ! check_command "kubectl" "kubectl"; then
    echo "  -> Install kubectl: https://kubernetes.io/docs/tasks/tools/"
    MISSING=1
fi

# Minikube
if ! check_command "minikube" "Minikube"; then
    echo "  -> Install Minikube: https://minikube.sigs.k8s.io/docs/start/"
    MISSING=1
fi

# Terraform
if ! check_command "terraform" "Terraform"; then
    echo "  -> Install Terraform: https://developer.hashicorp.com/terraform/install"
    MISSING=1
fi

echo ""

# Check Minikube status
if command -v minikube &> /dev/null; then
    echo "Checking Minikube status..."
    if minikube status &> /dev/null; then
        echo -e "${GREEN}[OK]${NC} Minikube is running"
    else
        echo -e "${YELLOW}[WARN]${NC} Minikube is not running"
        echo "  -> Start with: minikube start --driver=docker"
    fi
fi

echo ""

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}All prerequisites are installed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Start Minikube:  minikube start --driver=docker"
    echo "  2. Build Docker:    ./scripts/deploy-docker.sh"
    echo "  3. Deploy to K8s:   ./scripts/deploy-k8s.sh"
    echo "  4. Or use Terraform: ./scripts/deploy-terraform.sh"
else
    echo -e "${RED}Some prerequisites are missing. Please install them first.${NC}"
    exit 1
fi
