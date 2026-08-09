resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version

  # This holds the entire cluster PKI: Talos CA, Kubernetes CA, etcd CA, aggregator
  # CA, service-account key and the bootstrap/trustd tokens. Destroying and letting
  # Terraform regenerate it would issue brand-new CAs, and every downstream resource
  # would then push configs signed by a foreign CA to the running nodes. That is
  # cluster-destroying, not drift.
  #
  # Imported from secrets.yaml, and nothing about it should ever change. The import
  # records talos_version as "v1.3" against the config's "v1.11.3", which would
  # otherwise show as a permanent update on the resource holding the cluster PKI.
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
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
  # Deliberately NOT depends_on talos_machine_configuration_apply.controlplane.
  # depends_on references the whole resource, so naming it dragged all three control
  # plane instances into the graph of any targeted worker operation -- there was no
  # -target combination that could touch one worker without also re-applying config to
  # every master. Talos tolerates a worker being configured before the control plane is
  # reachable (it retries), so the ordering this bought was not worth losing the ability
  # to act on one node at a time.
  depends_on                  = [proxmox_virtual_environment_vm.worker]
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
