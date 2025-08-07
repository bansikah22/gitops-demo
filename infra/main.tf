terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = ">= 1.4.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  # Inherits configuration from kubernetes provider
}

provider "argocd" {
  server_addr = "localhost:8080"        # port-forward Argo CD server before running Terraform apply
  username    = "admin"
  password    = var.argocd_admin_password
  insecure    = true
}

# Create argocd namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Install Argo CD via Helm chart
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"

  create_namespace = false

  values = [
    file("${path.module}/values.yaml") # to customize Argo CD config values
  ]
}

# Define Argo CD Application for MailHog app
resource "argocd_application" "mailhog" {
  metadata {
    name      = "mailhog-demo"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/bansikah22/gitops-demo"
      target_revision = "HEAD"
      path            = "apps/overlays/dev"
      # helm { }        # when switched to helm apps in the repo, specify helm block here
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "dev"
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
}

