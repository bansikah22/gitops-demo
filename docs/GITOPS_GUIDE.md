# GitOps Workflow Guide

## How to Check Pods and Monitor GitOps

### 1. **Check Pod Status**
```bash
# Check all pods in dev namespace
kubectl get pods -n dev

# Check specific MailHog pods
kubectl get pods -l app=mailhog-demo -n dev

# Get detailed pod information
kubectl describe pod -l app=mailhog-demo -n dev

# Check pod logs
kubectl logs -f -l app=mailhog-demo -n dev
```

### 2. **Monitor ArgoCD Application**
```bash
# Check ArgoCD application status
kubectl get applications -n argocd

# Get detailed application information
kubectl describe application mailhog-demo -n argocd

# Watch application sync in real-time
kubectl get applications -n argocd -w
```

### 3. **Access MailHog Web Interface**

#### Method 1: Minikube Service
```bash
# Get the service URL
minikube service dev-mailhog-demo --url -n dev

# Open in browser
minikube service dev-mailhog-demo -n dev
```

#### Method 2: Port Forwarding
```bash
# Forward service port
kubectl port-forward svc/dev-mailhog-demo -n dev 8025:8025 &

# Access at: http://localhost:8025
```

#### Method 3: Direct Pod Access
```bash
# Forward pod port
kubectl port-forward pod/$(kubectl get pods -n dev -l app=mailhog-demo -o jsonpath='{.items[0].metadata.name}') -n dev 8025:8025 &

# Access at: http://localhost:8025
```

### 4. **Test MailHog SMTP**
```bash
# Get pod name
POD_NAME=$(kubectl get pods -n dev -l app=mailhog-demo -o jsonpath='{.items[0].metadata.name}')

# Test SMTP connection
kubectl exec -it $POD_NAME -n dev -- telnet localhost 1025

# Send test email
echo "Subject: Test Email" | kubectl exec -i $POD_NAME -n dev -- nc localhost 1025
```

## Understanding GitOps Workflow

### What is GitOps?
GitOps is a way to manage infrastructure and applications where **Git is the single source of truth**. Changes to your application are made in Git, and ArgoCD automatically syncs those changes to your Kubernetes cluster.

### How It Works:
1. **You make changes** to files in your Git repository
2. **You push changes** to GitHub
3. **ArgoCD detects** the changes automatically
4. **ArgoCD syncs** the changes to Kubernetes
5. **Your application updates** automatically

### Testing the GitOps Workflow:

#### Step 1: Make a Change
```bash
# Edit the MailHog version
vim apps/base/deployment.yaml
# Change: image: mailhog/mailhog:v1.0.1
# To: image: mailhog/mailhog:latest
```

#### Step 2: Push to GitHub
```bash
git add apps/base/deployment.yaml
git commit -m "Update MailHog to latest version"
git push origin master
```

#### Step 3: Watch ArgoCD Sync
```bash
# Watch the application sync
kubectl get applications -n argocd -w

# Check pod rollout
kubectl get pods -n dev -w
```

#### Step 4: Verify the Change
```bash
# Check the new image
kubectl describe pod -l app=mailhog-demo -n dev | grep Image

# Access MailHog to see it's working
kubectl port-forward svc/dev-mailhog-demo -n dev 8025:8025 &
```

## Monitoring Commands

### Quick Status Check
```bash
# Run the monitoring script
./monitor-gitops.sh
```

### Detailed Monitoring
```bash
# Check ArgoCD events
kubectl get events -n argocd --sort-by='.lastTimestamp'

# Check application events
kubectl get events -n dev --sort-by='.lastTimestamp'

# Monitor ArgoCD controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f
```

### Service Discovery
```bash
# Check service endpoints
kubectl get endpoints -n dev

# Check service details
kubectl describe svc dev-mailhog-demo -n dev
```

## Troubleshooting

### Common Issues:

#### 1. **Pod Not Starting**
```bash
# Check pod events
kubectl describe pod -l app=mailhog-demo -n dev

# Check pod logs
kubectl logs -l app=mailhog-demo -n dev
```

#### 2. **ArgoCD Not Syncing**
```bash
# Check ArgoCD application status
kubectl describe application mailhog-demo -n argocd

# Check ArgoCD controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

#### 3. **Service Not Accessible**
```bash
# Check service exists
kubectl get svc -n dev

# Check endpoints
kubectl get endpoints -n dev

# Test port forwarding
kubectl port-forward svc/dev-mailhog-demo -n dev 8025:8025
```

## Version Testing

### Test Different MailHog Versions:
```bash
# Use the version testing script
./test-versions.sh
```

### Manual Version Testing:
```bash
# Update to specific version
sed -i 's|image: mailhog/mailhog:[^[:space:]]*|image: mailhog/mailhog:latest|g' apps/base/deployment.yaml

# Commit and push
git add apps/base/deployment.yaml
git commit -m "Update to latest version"
git push origin master

# Watch the sync
kubectl get applications -n argocd -w
```

## Key Takeaways

1. **Git is the Source of Truth**: All changes go through Git
2. **ArgoCD Automates Sync**: No manual kubectl apply needed
3. **Declarative**: You describe what you want, not how to do it
4. **Auditable**: All changes are tracked in Git history
5. **Reversible**: Easy to rollback by reverting Git commits

This GitOps approach ensures your infrastructure is always in sync with your Git repository, making deployments predictable and auditable. 