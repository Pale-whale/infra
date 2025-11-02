resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.default_proxmox_node

  file_name               = "talos-${var.talos_version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/${var.talos_schematic}/${var.talos_version}/nocloud-amd64.raw.zst"
  decompression_algorithm = "zst"
  overwrite               = false
}

