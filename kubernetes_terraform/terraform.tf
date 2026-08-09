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
      version = "0.111.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
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

# These previously derived their credentials from talos_cluster_kubeconfig.kubeconfig.
# That is a hard cycle: the talos provider has no ImportState for that resource, so it
# can never be in state, so provider configuration is never resolvable, so Terraform
# refuses to run `import` at all -- "The configuration for provider[...kubernetes]
# depends on values that cannot be determined until apply." Deriving provider config
# from a managed resource is the documented way to get stuck like this.
#
# Reading a kubeconfig file instead breaks the cycle permanently. The context is pinned
# so this can never silently act on whatever cluster happens to be current.
# On a greenfield build, write `terraform output -raw kubeconfig` to disk after the
# talos stages and re-run; that is the same two-phase shape as var.bootstrap_phase.
provider "helm" {
  kubernetes = {
    config_path    = pathexpand(var.kubeconfig_path)
    config_context = var.cluster_name
  }
}

provider "kubernetes" {
  config_path    = pathexpand(var.kubeconfig_path)
  config_context = var.cluster_name
}

provider "github" {} # Rights needed: write:ssh_keys

provider "tls" {}
