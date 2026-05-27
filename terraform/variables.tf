# =============================================================
# Terraform Variables
# =============================================================
# LEARN: Variables make your Terraform configs reusable.
# You can set values via:
#   1. terraform.tfvars file
#   2. -var flag: terraform apply -var="app_name=myapp"
#   3. Environment variables: TF_VAR_app_name=myapp
# =============================================================

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = "minikube"
}

variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "poc-app-tf"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "poc-app"
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "container_image" {
  description = "Container image for the application"
  type        = string
  default     = "poc-app:latest"
}

variable "replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 5000
}

variable "service_port" {
  description = "Port exposed by the Kubernetes service"
  type        = number
  default     = 80
}

variable "node_port" {
  description = "NodePort for external access (30000-32767)"
  type        = number
  default     = 30090
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "cpu_request" {
  description = "CPU request for each pod"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory request for each pod"
  type        = string
  default     = "128Mi"
}

variable "cpu_limit" {
  description = "CPU limit for each pod"
  type        = string
  default     = "250m"
}

variable "memory_limit" {
  description = "Memory limit for each pod"
  type        = string
  default     = "256Mi"
}
