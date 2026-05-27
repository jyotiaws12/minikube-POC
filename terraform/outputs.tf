# =============================================================
# Terraform Outputs
# =============================================================
# LEARN: Outputs display useful information after terraform apply.
# They can also be used to pass data between Terraform modules.
# =============================================================

output "namespace" {
  description = "The namespace where resources are deployed"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "deployment_name" {
  description = "Name of the deployment"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "clusterip_service" {
  description = "ClusterIP service name"
  value       = kubernetes_service.clusterip.metadata[0].name
}

output "nodeport_service" {
  description = "NodePort service name and port"
  value = {
    name      = kubernetes_service.nodeport.metadata[0].name
    node_port = var.node_port
  }
}

output "access_instructions" {
  description = "How to access the application"
  value       = "Run: minikube service ${var.app_name}-nodeport -n ${var.namespace}"
}
