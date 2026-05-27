# =============================================================
# Service Resources
# =============================================================
# LEARN: Terraform lets you create multiple related resources
# in the same file with clear dependency references.
#
# Notice how we reference other resources:
#   kubernetes_namespace.app.metadata[0].name
# This creates an implicit dependency - Terraform knows to
# create the namespace BEFORE the service.
# =============================================================

# --- ClusterIP Service ---
resource "kubernetes_service" "clusterip" {
  metadata {
    name      = "${var.app_name}-clusterip"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app        = var.app_name
      managed_by = "terraform"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = var.app_name
    }

    port {
      port        = var.service_port
      target_port = var.container_port
      protocol    = "TCP"
    }
  }
}

# --- NodePort Service ---
resource "kubernetes_service" "nodeport" {
  metadata {
    name      = "${var.app_name}-nodeport"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app        = var.app_name
      managed_by = "terraform"
    }
  }

  spec {
    type = "NodePort"

    selector = {
      app = var.app_name
    }

    port {
      port        = var.service_port
      target_port = var.container_port
      node_port   = var.node_port
      protocol    = "TCP"
    }
  }
}
