# =============================================================
# Namespace Resource
# =============================================================
# LEARN: In Terraform, each resource block defines one piece
# of infrastructure. This creates a Kubernetes namespace.
#
# Compare with: kubernetes/01-namespace.yaml
# Same result, different approach (declarative IaC vs kubectl)
# =============================================================

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace

    labels = {
      project     = "k8s-docker-terraform-poc"
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}
