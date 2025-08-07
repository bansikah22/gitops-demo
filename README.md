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
- GitHub repository (for GitOps workflow)

### GitHub Setup
```bash
# Initialize Git repository (if not already done)
git init
git remote add origin https://github.com/YOUR_USERNAME/gitops-demo.git

# Push initial code to GitHub
git add .
git commit -m "Initial GitOps demo setup"
git push -u origin master
```

**Note**: ArgoCD needs access to your GitHub repository. Make sure the repository is public or configure SSH keys for private repos.

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
terraform apply -target=helm_release.argocd -auto-approve

## this is to install argocd apps
terraform apply -var="argocd_admin_password=<your-argocd-admin-password>" -auto-approve

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
kubectl apply -f ../apps/mailhog-app.yaml -n argocd

# create the dev namespace (if not exists)
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# ------------------------------------------------------------
# 5. Verify Deployment
# ------------------------------------------------------------
# check ArgoCD applications
kubectl get applications -n argocd

# check pods and services
kubectl get pods,svc

# expose the mailhog-demo service from minikube
minikube service dev-mailhog-demo --url -n dev

# Access MailHog UI
echo "MailHog UI available at: http://$(minikube service dev-mailhog-demo --url -n dev | head -1)"

# ------------------------------------------------------------
# 6. Monitor GitOps Workflow
# ------------------------------------------------------------
# Check ArgoCD application status
kubectl get applications -n argocd
kubectl describe application mailhog-demo -n argocd

# Check application pods and services
kubectl get pods,svc -n dev
kubectl describe pod -l app=mailhog-demo -n dev

# Monitor ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f

# Check application events
kubectl get events -n dev --sort-by='.lastTimestamp'

# ------------------------------------------------------------
# 7. Test GitOps Workflow
# ------------------------------------------------------------
# Make a change to the application (e.g., update image version)
# Edit apps/base/deployment.yaml and change the image version
# Then push to GitHub and watch ArgoCD sync automatically

# Example: Update MailHog version
# Change from: mailhog/mailhog:v1.0.1
# To: mailhog/mailhog:latest

# ------------------------------------------------------------
# 8. Access MailHog Web Interface
# ------------------------------------------------------------
# Method 1: Using minikube service
minikube service dev-mailhog-demo --url -n dev

# Method 2: Port forwarding
kubectl port-forward svc/dev-mailhog-demo -n dev 8025:8025 &
echo "MailHog UI: http://localhost:8025"

# Method 3: Direct pod access
kubectl port-forward pod/$(kubectl get pods -n dev -l app=mailhog-demo -o jsonpath='{.items[0].metadata.name}') -n dev 8025:8025 &
echo "MailHog UI: http://localhost:8025"

# ------------------------------------------------------------
# 9. Test MailHog SMTP
# ------------------------------------------------------------
# Send test email to MailHog
echo "Subject: Test Email" | kubectl exec -i $(kubectl get pods -n dev -l app=mailhog-demo -o jsonpath='{.items[0].metadata.name}') -n dev -- nc localhost 1025

# Or use telnet to test SMTP
kubectl exec -it $(kubectl get pods -n dev -l app=mailhog-demo -o jsonpath='{.items[0].metadata.name}') -n dev -- telnet localhost 1025

---

## 🤝 Contributing
Contributions are welcome! Please open issues and pull requests.

## 📜 License
This project is licensed under the terms of the [MIT License](LICENSE).

## 🔄 GitOps Workflow with GitHub

### Pushing Changes to GitHub
```bash
# Add all changes
git add .

# Commit changes
git commit -m "Update MailHog configuration"

# Push to GitHub
git push origin master
```

### Testing Different Versions
1. **Update MailHog Version**:
   ```bash
   # Edit apps/base/deployment.yaml
   # Change image: mailhog/mailhog:v1.0.1 to mailhog/mailhog:latest
   ```

2. **Update Resource Limits**:
   ```bash
   # Edit apps/overlays/prod/kustomization.yaml
   # Modify CPU/memory limits for production
   ```

3. **Add New Environment**:
   ```bash
   # Create apps/overlays/staging/kustomization.yaml
   # Configure staging-specific settings
   ```

### Monitoring GitOps Sync
```bash
# Watch ArgoCD sync in real-time
kubectl get applications -n argocd -w

# Check sync status
kubectl describe application mailhog-demo -n argocd

# View ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
# Open: https://localhost:8080

# Use the monitoring script
./monitor-gitops.sh

# Test different versions
./test-versions.sh

# View detailed documentation
# See docs/ directory for comprehensive guides
```

## 📚 References
- [Argo CD Documentation](https://argo-cd.readthedocs.io/en/stable/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/)
