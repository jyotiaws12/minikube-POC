# Exercise 3: Terraform Basics

## Prerequisites
- Terraform installed (`terraform --version`)
- Minikube running (`minikube start --driver=docker`)
- Docker image built in Minikube (see Exercise 2 prerequisites)

---

## Exercise 3.1: Understanding Terraform Files

Review the files in `terraform/` and answer:
1. What does `providers.tf` do?
2. What's the difference between `variables.tf` and `terraform.tfvars`?
3. What are `outputs.tf` used for?

<details>
<summary>Answers</summary>

1. **providers.tf** configures which plugins Terraform uses (here: Kubernetes provider) and how to connect (kubeconfig path).
2. **variables.tf** declares variables with types, descriptions, and defaults. **terraform.tfvars** sets actual values for those variables.
3. **outputs.tf** displays useful info after `terraform apply` and can pass data between modules.
</details>

---

## Exercise 3.2: Terraform Init

```bash
cd terraform/

# Initialize Terraform (downloads providers)
terraform init

# See what was downloaded
ls -la .terraform/providers/
```

**What happened?** Terraform downloaded the Kubernetes provider plugin.

---

## Exercise 3.3: Terraform Plan

```bash
# See what Terraform WILL do (without changing anything)
terraform plan

# Save the plan to a file
terraform plan -out=myplan

# Show the saved plan
terraform show myplan
```

**Key concept:** `plan` is a dry run. It shows you exactly what will be created, changed, or destroyed. Always review before applying!

---

## Exercise 3.4: Terraform Apply

```bash
# Apply the saved plan
terraform apply myplan

# Or apply interactively (will show plan and ask for confirmation)
terraform apply

# Check the outputs
terraform output
```

Verify the deployment:
```bash
kubectl get all -n poc-app-tf
minikube service poc-app-nodeport -n poc-app-tf
```

---

## Exercise 3.5: Terraform State

```bash
# List all managed resources
terraform state list

# Show details of a specific resource
terraform state show kubernetes_deployment.app

# Show the full state
terraform show
```

**Key concept:** Terraform tracks all resources it manages in a **state file** (`terraform.tfstate`). This is how it knows what exists and what needs to change.

---

## Exercise 3.6: Making Changes

```bash
# Change the number of replicas via variable
terraform apply -var="replicas=3"

# Watch the new pod appear
kubectl get pods -n poc-app-tf -w

# Change the environment
terraform apply -var="environment=staging"

# Check the app
curl $(minikube service poc-app-nodeport -n poc-app-tf --url)/info
```

---

## Exercise 3.7: Terraform Destroy

```bash
# See what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Verify cleanup
kubectl get namespace poc-app-tf
```

**Key concept:** `destroy` removes all resources managed by Terraform. This is the clean opposite of `apply`.

---

## Exercise 3.8: Variables and Overrides

```bash
# Use different variable values
terraform apply \
    -var="replicas=3" \
    -var="environment=staging" \
    -var="node_port=30091"

# Use a different tfvars file
cat > staging.tfvars <<EOF
namespace   = "poc-staging"
replicas    = 3
environment = "staging"
node_port   = 30091
EOF

terraform apply -var-file="staging.tfvars"
```

---

## Comparison: kubectl vs Terraform

| Feature                | kubectl              | Terraform                |
|------------------------|----------------------|--------------------------|
| Config format          | YAML                 | HCL                      |
| State tracking         | No                   | Yes (terraform.tfstate)  |
| Drift detection        | No                   | Yes (`terraform plan`)   |
| Dependencies           | Manual ordering      | Automatic (graph-based)  |
| Rollback               | `rollout undo`       | Apply previous state     |
| Multi-cloud            | K8s only             | Any provider             |
| Learning curve         | Lower                | Higher                   |
| Best for               | Quick deployments    | Infrastructure as Code   |

---

## Challenge Exercise

1. Add a new Terraform resource: `kubernetes_horizontal_pod_autoscaler`
2. Reference the deployment created by `kubernetes_deployment.app`
3. Set min replicas to 2, max to 5, target CPU utilization to 50%
4. Run `terraform plan` to preview, then `terraform apply`
5. Verify with `kubectl get hpa -n poc-app-tf`

Hint: Check the [Terraform K8s provider docs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/horizontal_pod_autoscaler_v2)
