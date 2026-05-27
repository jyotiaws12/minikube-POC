# =============================================================
# Terraform Provider Configuration
# =============================================================
# LEARN: Providers are plugins that Terraform uses to interact
# with cloud providers, SaaS providers, and other APIs.
# Here we use the Kubernetes provider to manage K8s resources.
# =============================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.0"
    }
  }
}

# Configure the Kubernetes provider to use your local kubeconfig
# This works with Minikube out of the box!
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}
