variable "kube_config" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "argocd_admin_password" {
  description = "Initial admin password for Argo CD (retrieved from secret or set manually)"
  type        = string
}