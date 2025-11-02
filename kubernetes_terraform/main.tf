resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.default_proxmox_node

  file_name = "talos-${var.talos_version}-nocloud-amd64.raw"
  url       = "https://factory.talos.dev/image/${var.talos_schematic}/${var.talos_version}/nocloud-amd64.raw"
  overwrite = false
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controlplane[keys(local.controlplane)[0]].ip
}

data "talos_cluster_health" "health_no_cilium" {
  count                = var.deploy_cilium_cni ? 0 : 1
  depends_on           = [talos_machine_configuration_apply.controlplane, talos_machine_configuration_apply.worker]
  client_configuration = data.talos_client_configuration.homelab.client_configuration
  control_plane_nodes  = [for n in local.controlplane : n.ip]
  worker_nodes         = [for n in local.workers : n.ip]
  endpoints            = data.talos_client_configuration.homelab.endpoints
}

data "talos_cluster_health" "health_with_cilium" {
  count                = var.deploy_cilium_cni ? 1 : 0
  depends_on           = [helm_release.cilium]
  client_configuration = data.talos_client_configuration.homelab.client_configuration
  control_plane_nodes  = [for n in local.controlplane : n.ip]
  worker_nodes         = [for n in local.workers : n.ip]
  endpoints            = data.talos_client_configuration.homelab.endpoints
}
