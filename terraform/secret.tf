# =============================================================
# Secret Resource
# =============================================================
# LEARN: Terraform can manage Kubernetes Secrets, but be aware:
#   - Secret values are stored in Terraform state (in plain text!)
#   - In production, use tools like HashiCorp Vault or AWS
#     Secrets Manager with Terraform's vault provider
#   - Mark sensitive variables with `sensitive = true`
# =============================================================

resource "kubernetes_secret" "app" {
  metadata {
    name      = "${var.app_name}-secret"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app        = var.app_name
      managed_by = "terraform"
    }
  }

  type = "Opaque"

  data = {
    SECRET_KEY  = "super-secret-key-123"
    DB_PASSWORD = "db-password-456"
  }
}
