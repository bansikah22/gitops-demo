# GitOps Demo with Terraform, Argo CD, and Kubernetes

[![License](https://img.shields.io/github/license/bansikah22/gitops-demo)](LICENSE)
[![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-blue)](https://argo-cd.readthedocs.io/en/stable/)
[![Terraform](https://img.shields.io/badge/Terraform-Infra%20as%20Code-purple)](https://www.terraform.io/)

A minimal but real-life **GitOps demo** using:
- **Terraform** to provision infrastructure and Argo CD
- **Argo CD** to manage applications in Kubernetes (Minikube)
- **Kubernetes** as the deployment platform

This project demonstrates the GitOps workflow where Git is the **single source of truth** for both infrastructure and applications.

## 🚀 Getting Started

### Prerequisites
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Git

```bash
# ------------------------------------------------------------
# 1. Start Minikube
# ------------------------------------------------------------
minikube start ## use default resources

# verify cluster
kubectl get nodes

# ------------------------------------------------------------
# 2. Install Argo CD with Terraform
# ------------------------------------------------------------
cd gitops-demo/infra

# init and apply terraform
terraform init
terraform apply -auto-approve

## install argocd manaully
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# ------------------------------------------------------------
# 3. Access Argo CD
# ------------------------------------------------------------
# forward Argo CD API server to localhost
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
sleep 5

echo "Open ArgoCD UI at: https://localhost:8080"
echo "Username: admin"

# get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# ------------------------------------------------------------
# 4. Register App with Argo CD
# ------------------------------------------------------------
# apply the Application manifest from your repo
kubectl apply -f ../apps/nginx-app.yaml -n argocd

# ------------------------------------------------------------
# 5. Verify Deployment
# ------------------------------------------------------------
# check ArgoCD applications
kubectl get applications -n argocd

# check pods and services
kubectl get pods,svc

# expose the nginx-demo service from minikube
minikube service nginx-demo --url
```

---

## 🤝 Contributing
Contributions are welcome! Please open issues and pull requests.

## 📜 License
This project is licensed under the terms of the [MIT License](LICENSE).

## 📚 References
- [Argo CD Documentation](https://argo-cd.readthedocs.io/en/stable/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/)
