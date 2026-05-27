# =============================================================
# Variable Values (terraform.tfvars)
# =============================================================
# LEARN: This file sets default values for your variables.
# Terraform automatically loads this file.
# You can override with: terraform apply -var="replicas=3"
# =============================================================

namespace    = "poc-app-tf"
app_name     = "poc-app"
app_version  = "1.0.0"
replicas     = 2
environment  = "development"
