#!/bin/bash

# GitOps Monitoring Script
# This script helps monitor the GitOps workflow with ArgoCD

set -e

echo "GitOps Monitoring Dashboard"
echo "=========================="

# Check ArgoCD status
echo ""
echo "ArgoCD Application Status:"
kubectl get applications -n argocd

echo ""
echo "Application Details:"
kubectl describe application mailhog-demo -n argocd | grep -E "(Status|Sync|Health)" || echo "Application not found yet"

# Check pods and services
echo ""
echo "Pods and Services in dev namespace:"
kubectl get pods,svc -n dev

# Check pod details
echo ""
echo "Pod Details:"
POD_NAME=$(kubectl get pods -n dev -l app=mailhog-demo -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "No pods found")
if [ "$POD_NAME" != "No pods found" ]; then
    echo "Pod: $POD_NAME"
    kubectl describe pod $POD_NAME -n dev | grep -E "(Status|Events|Conditions)" || echo "Pod not ready yet"
else
    echo "No MailHog pods found in dev namespace"
fi

# Check recent events
echo ""
echo "Recent Events in dev namespace:"
kubectl get events -n dev --sort-by='.lastTimestamp' | tail -5

# Check ArgoCD controller logs
echo ""
echo "ArgoCD Controller Logs (last 10 lines):"
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=10 2>/dev/null || echo "ArgoCD controller not found"

# Check service endpoints
echo ""
echo "Service Endpoints:"
kubectl get endpoints -n dev

# Check if MailHog is accessible
echo ""
echo "MailHog Access URLs:"
echo "Method 1 (Minikube):"
minikube service dev-mailhog-demo --url -n dev 2>/dev/null || echo "Service not available yet"

echo ""
echo "Method 2 (Port Forward):"
echo "Run: kubectl port-forward svc/dev-mailhog-demo -n dev 8025:8025"
echo "Then access: http://localhost:8025"

echo ""
echo "SMTP Access:"
echo "SMTP Server: $(kubectl get svc dev-mailhog-demo -n dev -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "Not available"):1025"

echo ""
echo "GitOps Workflow Commands:"
echo "1. Watch ArgoCD sync: kubectl get applications -n argocd -w"
echo "2. Check sync status: kubectl describe application mailhog-demo -n argocd"
echo "3. View ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "4. Monitor pod logs: kubectl logs -f $POD_NAME -n dev"
echo "5. Test GitOps: Make changes to Git repo and watch ArgoCD sync automatically"

echo ""
echo "Monitoring complete!" 