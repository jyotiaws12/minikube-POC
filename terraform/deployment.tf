# =============================================================
# Deployment Resource
# =============================================================
# LEARN: This is the Terraform equivalent of 04-deployment.yaml.
# Notice how Terraform uses HCL (HashiCorp Configuration Language)
# instead of YAML. Both achieve the same result!
#
# Key Terraform advantage: You can use variables, conditionals,
# loops, and reference other resources dynamically.
# =============================================================

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app        = var.app_name
      managed_by = "terraform"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = var.app_version
        }
      }

      spec {
        container {
          name              = var.app_name
          image             = var.container_image
          image_pull_policy = "Never"  # For Minikube local images

          port {
            container_port = var.container_port
            protocol       = "TCP"
          }

          # Environment from ConfigMap
          env_from {
            config_map_ref {
              name = kubernetes_config_map.app.metadata[0].name
            }
          }

          # Environment from Secret
          env {
            name = "SECRET_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app.metadata[0].name
                key  = "SECRET_KEY"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app.metadata[0].name
                key  = "DB_PASSWORD"
              }
            }
          }

          # Resource limits
          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          # Liveness probe
          liveness_probe {
            http_get {
              path = "/health"
              port = var.container_port
            }
            initial_delay_seconds = 10
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          # Readiness probe
          readiness_probe {
            http_get {
              path = "/ready"
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }
      }
    }
  }

  # Wait for the deployment to be ready
  timeouts {
    create = "3m"
    update = "3m"
  }
}
