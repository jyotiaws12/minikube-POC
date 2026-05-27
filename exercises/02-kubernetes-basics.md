# Exercise 2: Kubernetes Basics

## Prerequisites
- Minikube installed and running (`minikube start --driver=docker`)
- kubectl installed
- Docker image built inside Minikube (see below)

```bash
# Build the image inside Minikube's Docker daemon
eval $(minikube docker-env)
docker build -t poc-app:latest -f docker/Dockerfile .
```

---

## Exercise 2.1: Namespaces

```bash
# Create the namespace
kubectl apply -f kubernetes/01-namespace.yaml

# List all namespaces
kubectl get namespaces

# Describe the namespace
kubectl describe namespace poc-app
```

**Question:** Why use namespaces instead of deploying everything to `default`?

<details>
<summary>Answer</summary>
Namespaces provide isolation, resource quotas, access control (RBAC), and organization. Teams can have separate namespaces with their own resource limits.
</details>

---

## Exercise 2.2: ConfigMaps and Secrets

```bash
# Create ConfigMap and Secret
kubectl apply -f kubernetes/02-configmap.yaml
kubectl apply -f kubernetes/03-secret.yaml

# View the ConfigMap
kubectl get configmap poc-app-config -n poc-app -o yaml

# View the Secret (base64 encoded)
kubectl get secret poc-app-secret -n poc-app -o yaml

# Decode a secret value
kubectl get secret poc-app-secret -n poc-app -o jsonpath='{.data.SECRET_KEY}' | base64 -d
echo ""
```

**Exercise:** Create a new ConfigMap from a literal value:
```bash
kubectl create configmap my-config --from-literal=MY_VAR=hello -n poc-app
kubectl get configmap my-config -n poc-app -o yaml
```

---

## Exercise 2.3: Deployments

```bash
# Deploy the application
kubectl apply -f kubernetes/04-deployment.yaml

# Watch pods come up
kubectl get pods -n poc-app -w

# Check deployment status
kubectl get deployment poc-app -n poc-app
kubectl describe deployment poc-app -n poc-app

# Check pod details
kubectl get pods -n poc-app -o wide
kubectl describe pod <pod-name> -n poc-app
```

---

## Exercise 2.4: Services

```bash
# Create services
kubectl apply -f kubernetes/05-service.yaml

# List services
kubectl get svc -n poc-app

# Access via Minikube
minikube service poc-app-nodeport -n poc-app

# Or port-forward (works for ClusterIP too!)
kubectl port-forward svc/poc-app-clusterip 8080:80 -n poc-app
# Open http://localhost:8080 in your browser
```

---

## Exercise 2.5: Scaling

```bash
# Manual scaling
kubectl scale deployment poc-app -n poc-app --replicas=4
kubectl get pods -n poc-app -w

# Watch the pods come up
kubectl get pods -n poc-app

# Scale back down
kubectl scale deployment poc-app -n poc-app --replicas=2

# Deploy the HPA
kubectl apply -f kubernetes/07-hpa.yaml
kubectl get hpa -n poc-app
```

---

## Exercise 2.6: Rolling Updates

```bash
# Change the environment variable to simulate an update
kubectl set env deployment/poc-app -n poc-app APP_VERSION=2.0.0

# Watch the rolling update
kubectl rollout status deployment/poc-app -n poc-app

# Check rollout history
kubectl rollout history deployment/poc-app -n poc-app

# Rollback if needed
kubectl rollout undo deployment/poc-app -n poc-app
```

---

## Exercise 2.7: Debugging

```bash
# View pod logs
kubectl logs -f <pod-name> -n poc-app

# Execute a command inside a pod
kubectl exec -it <pod-name> -n poc-app -- /bin/bash

# Inside the pod:
curl localhost:5000/health
env | grep APP
exit

# View events
kubectl get events -n poc-app --sort-by='.lastTimestamp'

# Check resource usage (requires metrics-server)
minikube addons enable metrics-server
kubectl top pods -n poc-app
kubectl top nodes
```

---

## Exercise 2.8: View Everything

```bash
# See all resources in the namespace
kubectl get all -n poc-app

# Detailed view
kubectl get pods,svc,deploy,configmap,secret,hpa -n poc-app
```

---

## Challenge Exercise

1. Create a second deployment called `poc-app-v2` with `APP_VERSION=2.0.0`
2. Create a Service that load-balances between both versions (hint: use the same label selector)
3. Observe that requests alternate between v1 and v2 pods (canary deployment pattern)
