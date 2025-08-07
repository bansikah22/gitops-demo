# Documentation

This directory contains comprehensive documentation for the GitOps demo project.

## Available Documentation

### [GitOps Guide](GITOPS_GUIDE.md)
Complete guide for understanding and monitoring the GitOps workflow, including:
- How to check pods and services
- Multiple ways to access MailHog
- Understanding GitOps workflow
- Troubleshooting common issues
- Version testing procedures

## Quick Reference

### Monitoring Scripts
- `../monitor-gitops.sh` - Complete monitoring dashboard
- `../test-versions.sh` - Version testing tool

### Key Commands
```bash
# Check pods
kubectl get pods -n dev

# Monitor ArgoCD sync
kubectl get applications -n argocd -w

# Access MailHog
kubectl port-forward svc/dev-mailhog-demo -n dev 8025:8025

# Run monitoring script
./monitor-gitops.sh
```

### GitOps Workflow
1. Make changes to Git repository
2. Push changes to GitHub
3. ArgoCD detects changes automatically
4. ArgoCD syncs changes to Kubernetes
5. Application updates automatically

For detailed instructions, see the [GitOps Guide](GITOPS_GUIDE.md). 