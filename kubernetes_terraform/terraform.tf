# ─────────────────────────────────────────────────────────────────────────────
# NEVER run `terraform apply` without -target against this module.
#
# Ten resources in this configuration cannot be imported (the talos provider
# implements ImportState on only machine_secrets and machine_bootstrap):
#   talos_machine_configuration_apply.{controlplane,worker}  x8
#   talos_cluster_kubeconfig.kubeconfig
#   talos_image_factory_schematic.this
# They will therefore ALWAYS show as "to create" against the live cluster. An
# untargeted apply would re-push machine configuration to all eight running
# nodes. The plan is expected to be non-empty forever; that is not drift.
# ─────────────────────────────────────────────────────────────────────────────
terraform {
  required_version = ">= 1.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.7.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.20.3:8006/"
  insecure  = true # Only needed if your Proxmox server is using a self-signed certificate
  api_token = var.proxmox_token
}

provider "talos" {}

provider "helm" {
  kubernetes = {
    host = "https://${var.kubeapi_address}:6443"

    client_certificate     = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.ca_certificate)
  }
}

provider "kubernetes" {
  host = "https://${var.kubeapi_address}:6443"

  client_certificate     = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.ca_certificate)
}

provider "github" {} # Rights needed: write:ssh_keys

provider "tls" {}
