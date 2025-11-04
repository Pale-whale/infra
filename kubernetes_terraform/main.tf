data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = concat(["qemu-guest-agent"], var.extra_talos_filters)
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
  architecture  = "amd64"
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.default_proxmox_node

  file_name = "talos-${var.talos_version}-${talos_image_factory_schematic.this.id}-nocloud-amd64.raw"
  url       = trimsuffix(data.talos_image_factory_urls.this.urls.disk_image, ".xz")
  overwrite = false
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controlplane[keys(local.controlplane)[0]].ip
}

data "talos_cluster_health" "health" {
  depends_on           = [talos_machine_configuration_apply.controlplane, talos_machine_configuration_apply.worker]
  client_configuration = data.talos_client_configuration.homelab.client_configuration
  control_plane_nodes  = [for n in local.controlplane : n.ip]
  worker_nodes         = [for n in local.workers : n.ip]
  endpoints            = data.talos_client_configuration.homelab.endpoints
}
