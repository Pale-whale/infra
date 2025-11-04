resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

data "talos_client_configuration" "homelab" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.kubeapi_address, var.kubeapi_fqdn]
}

locals {
  controlplane = {
    for name, spec in var.topology.controlplane :
    name => spec
  }
  workers = {
    for name, spec in var.topology.workers :
    name => spec
  }
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.kubeapi_address}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    templatefile("${path.module}/talos-config/default.yaml.tpl", {
      network_gateway   = var.default_gateway
      deploy_cilium_cni = var.deploy_cilium_cni
    }),
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on                  = [proxmox_virtual_environment_vm.controlplane]
  for_each                    = local.controlplane
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.controlplane[each.key].ip

  config_patches = [
    templatefile("${path.module}/talos-config/control-plane.yaml.tpl", {
      kubeapi_fqdn       = var.kubeapi_fqdn
      kubeapi_address    = var.kubeapi_address
      extra_sans         = var.kubeapi_extra_sans
      ipv4_local         = local.controlplane[each.key].ip
      network_gateway    = var.default_gateway
      hostname           = each.key
      network_ip_prefix  = "24"
      pod_subnet         = var.pod_subnet
      services_subnet    = var.services_subnet
      proxmox_datacenter = var.cluster_name
      vm_id              = local.controlplane[each.key].vm_id
    })
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controlplane[keys(local.controlplane)[0]].ip
}

data "talos_machine_configuration" "workers" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.kubeapi_address}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    templatefile("${path.module}/talos-config/default.yaml.tpl", {
      network_gateway   = var.default_gateway
      deploy_cilium_cni = var.deploy_cilium_cni
    }),
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on                  = [proxmox_virtual_environment_vm.worker, talos_machine_configuration_apply.controlplane]
  for_each                    = local.workers
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers.machine_configuration
  node                        = local.workers[each.key].ip

  config_patches = [
    templatefile("${path.module}/talos-config/worker.yaml.tpl", {
      hostname           = each.key
      network_interface  = "eth0"
      ipv4_local         = local.workers[each.key].ip
      network_ip_prefix  = "24"
      network_gateway    = var.default_gateway
      proxmox_datacenter = var.cluster_name
      vm_id              = local.workers[each.key].vm_id
    })
  ]
}
