# =============================================================
# ConfigMap Resource
# =============================================================
# LEARN: Terraform manages the ConfigMap lifecycle:
#   - terraform plan  -> shows what will change
#   - terraform apply -> creates/updates the ConfigMap
#   - terraform destroy -> removes it
#
# Advantage over kubectl: state tracking & drift detection
# =============================================================

resource "kubernetes_config_map" "app" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app        = var.app_name
      managed_by = "terraform"
    }
  }

  data = {
    APP_NAME    = "K8s-Docker-Terraform POC (via Terraform)"
    APP_VERSION = var.app_version
    ENVIRONMENT = var.environment
    PORT        = tostring(var.container_port)
  }
}
