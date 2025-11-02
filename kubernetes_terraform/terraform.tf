terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.1.69:8006/"
  insecure = true # Only needed if your Proxmox server is using a self-signed certificate
}
