#!/bin/bash

# MailHog Version Testing Script
# This script helps test different MailHog versions and demonstrate GitOps workflow

set -e

echo "MailHog Version Testing"
echo "======================="

# Function to update MailHog version
update_mailhog_version() {
    local version=$1
    echo "Updating MailHog to version: $version"
    
    # Update the deployment file
    sed -i.bak "s|image: mailhog/mailhog:[^[:space:]]*|image: mailhog/mailhog:$version|g" apps/base/deployment.yaml
    
    echo "Updated MailHog version to $version"
    echo "Changes made to apps/base/deployment.yaml"
}

# Function to show current version
show_current_version() {
    echo "Current MailHog version:"
    grep "image:" apps/base/deployment.yaml
}

# Function to commit and push changes
commit_and_push() {
    echo "Committing and pushing changes to GitHub..."
    git add apps/base/deployment.yaml
    git commit -m "Update MailHog version"
    git push origin master
    echo "Changes pushed to GitHub"
}

# Function to monitor sync
monitor_sync() {
    echo "Monitoring ArgoCD sync..."
    echo "Press Ctrl+C to stop monitoring"
    kubectl get applications -n argocd -w
}

# Main menu
echo ""
echo "Available actions:"
echo "1. Show current MailHog version"
echo "2. Update to MailHog v1.0.1 (stable)"
echo "3. Update to MailHog latest (latest)"
echo "4. Update to MailHog v1.0.0 (older)"
echo "5. Commit and push changes to GitHub"
echo "6. Monitor ArgoCD sync"
echo "7. Run all tests"
echo "8. Exit"

read -p "Choose an option (1-8): " choice

case $choice in
    1)
        show_current_version
        ;;
    2)
        update_mailhog_version "v1.0.1"
        ;;
    3)
        update_mailhog_version "latest"
        ;;
    4)
        update_mailhog_version "v1.0.0"
        ;;
    5)
        commit_and_push
        ;;
    6)
        monitor_sync
        ;;
    7)
        echo "Running all tests..."
        show_current_version
        update_mailhog_version "latest"
        commit_and_push
        echo "Waiting 30 seconds for ArgoCD to detect changes..."
        sleep 30
        monitor_sync
        ;;
    8)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "Next steps:"
echo "1. Run: ./monitor-gitops.sh to check deployment status"
echo "2. Access MailHog UI: kubectl port-forward svc/dev-mailhog-demo -n dev 8025:8025"
echo "3. Check ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443" 