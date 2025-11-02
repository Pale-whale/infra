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
}

resource "proxmox_virtual_environment_vm" "controlplane" {
  for_each = local.controlplane

  name          = each.key
  vm_id         = each.value.vm_id
  description   = "Talos Control Plane Node ${each.key} for ${var.cluster_name} Kubernetes Cluster"
  tags          = ["terraform", var.cluster_name, "talos", "controlplane"]
  node_name     = coalesce(each.value.proxmox_node, var.default_proxmox_node)
  on_boot       = true
  machine       = coalesce(each.value.machine, var.default_machine)
  tablet_device = false
  scsi_hardware = "virtio-scsi-single"

  boot_order = ["scsi1"]

  cpu {
    cores = coalesce(each.value.cpu, var.default_controlplane_cpu)
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = coalesce(each.value.memory, var.default_controlplane_memory)
  }

  vga {
    type = coalesce(each.value.vga, var.default_vga)
  }

  serial_device {
    device = "socket"
  }

  agent {
    enabled = true
  }

  network_device {
    bridge       = coalesce(each.value.network_device.bridge, var.default_network_device.bridge)
    disconnected = try(coalesce(each.value.network_device.disconnected, var.default_network_device.disconnected), null)
    enabled      = try(coalesce(each.value.network_device.enabled, var.default_network_device.enabled), null)
    firewall     = try(coalesce(each.value.network_device.firewall, var.default_network_device.firewall), null)
    mac_address  = try(coalesce(each.value.network_device.mac_address, var.default_network_device.mac_address), null)
    model        = try(coalesce(each.value.network_device.model, var.default_network_device.model), null)
    mtu          = try(coalesce(each.value.network_device.mtu, var.default_network_device.mtu), null)
    vlan_id      = try(coalesce(each.value.network_device.vlan_id, var.default_network_device.vlan_id), null)
    trunks       = try(coalesce(each.value.network_device.trunks, var.default_network_device.trunks), null)
  }

  disk {
    datastore_id = try(coalesce(each.value.disk.datastore_id, var.default_disk.datastore_id), null)
    import_from  = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = try(coalesce(each.value.disk.file_format, var.default_disk.file_format), null)
    interface    = try(coalesce(each.value.disk.interface, var.default_disk.interface), null)
    size         = try(coalesce(each.value.disk.size, var.default_disk.size), null)
    discard      = try(coalesce(each.value.disk.discard, var.default_disk.discard), null)
    ssd          = try(coalesce(each.value.disk.ssd, var.default_disk.ssd), null)
    iothread     = try(coalesce(each.value.disk.iothread, var.default_disk.iothread), null)
  }

  dynamic "disk" {
    for_each = each.value.additional_disks
    content {
      datastore_id      = try(disk.value.datastore_id, null)
      file_format       = try(disk.value.file_format, null)
      interface         = try(disk.value.interface, null)
      size              = try(disk.value.size, null)
      discard           = try(disk.value.discard, null)
      ssd               = try(disk.value.ssd, null)
      iothread          = try(disk.value.iothread, null)
      import_from       = try(disk.value.import_from, null)
      path_in_datastore = try(disk.value.path_in_datastore, null)
    }
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = var.default_cloud_init_datastore

    user_account {
      username = var.default_user_account.username
      password = var.default_user_account.password
    }
  }
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on                  = [proxmox_virtual_environment_vm.controlplane]
  for_each                    = local.controlplane
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = proxmox_virtual_environment_vm.controlplane[each.key].ipv4_addresses[0][0] #first ip of first network interface
  endpoint                    = proxmox_virtual_environment_vm.controlplane[each.key].ipv4_addresses[0][0] #first ip of first network interface
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = proxmox_virtual_environment_vm.controlplane[keys(local.controlplane)[0]].ipv4_addresses[0][0] #first ip of first network interface
}

data "talos_machine_configuration" "workers" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.kubeapi_address}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}

resource "proxmox_virtual_environment_vm" "worker" {
  for_each = local.workers

  name          = each.key
  vm_id         = each.value.vm_id
  description   = "Talos Worker Node ${each.key} for ${var.cluster_name} Kubernetes Cluster"
  tags          = ["terraform", var.cluster_name, "talos", "worker"]
  node_name     = coalesce(each.value.proxmox_node, var.default_proxmox_node)
  on_boot       = true
  machine       = coalesce(each.value.machine, var.default_machine)
  tablet_device = false
  scsi_hardware = "virtio-scsi-single"

  boot_order = ["scsi1"]

  cpu {
    cores = coalesce(each.value.cpu, var.default_controlplane_cpu)
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = coalesce(each.value.memory, var.default_controlplane_memory)
  }

  vga {
    type = coalesce(each.value.vga, var.default_vga)
  }

  serial_device {
    device = "socket"
  }

  agent {
    enabled = true
  }

  network_device {
    bridge       = coalesce(each.value.network_device.bridge, var.default_network_device.bridge)
    disconnected = try(coalesce(each.value.network_device.disconnected, var.default_network_device.disconnected), null)
    enabled      = try(coalesce(each.value.network_device.enabled, var.default_network_device.enabled), null)
    firewall     = try(coalesce(each.value.network_device.firewall, var.default_network_device.firewall), null)
    mac_address  = try(coalesce(each.value.network_device.mac_address, var.default_network_device.mac_address), null)
    model        = try(coalesce(each.value.network_device.model, var.default_network_device.model), null)
    mtu          = try(coalesce(each.value.network_device.mtu, var.default_network_device.mtu), null)
    vlan_id      = try(coalesce(each.value.network_device.vlan_id, var.default_network_device.vlan_id), null)
    trunks       = try(coalesce(each.value.network_device.trunks, var.default_network_device.trunks), null)
  }

  disk {
    datastore_id = try(coalesce(each.value.disk.datastore_id, var.default_disk.datastore_id), null)
    import_from  = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = try(coalesce(each.value.disk.file_format, var.default_disk.file_format), null)
    interface    = try(coalesce(each.value.disk.interface, var.default_disk.interface), null)
    size         = try(coalesce(each.value.disk.size, var.default_disk.size), null)
    discard      = try(coalesce(each.value.disk.discard, var.default_disk.discard), null)
    ssd          = try(coalesce(each.value.disk.ssd, var.default_disk.ssd), null)
    iothread     = try(coalesce(each.value.disk.iothread, var.default_disk.iothread), null)
  }

  dynamic "disk" {
    for_each = each.value.additional_disks
    content {
      datastore_id      = try(disk.value.datastore_id, null)
      file_format       = try(disk.value.file_format, null)
      interface         = try(disk.value.interface, null)
      size              = try(disk.value.size, null)
      discard           = try(disk.value.discard, null)
      ssd               = try(disk.value.ssd, null)
      iothread          = try(disk.value.iothread, null)
      import_from       = try(disk.value.import_from, null)
      path_in_datastore = try(disk.value.path_in_datastore, null)
    }
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = var.default_cloud_init_datastore

    user_account {
      username = var.default_user_account.username
      password = var.default_user_account.password
    }
  }

  dynamic "usb" {
    for_each = each.value.usb
    content {
      host = usb.value.host
      usb3 = try(usb.value.usb3, null)
    }
  }

  dynamic "hostpci" {
    for_each = each.value.hostpci
    content {
      device = hostpci.value.device
      id     = try(hostpci.value.id, null)
      pcie   = try(hostpci.value.pcie, null)
    }
  }
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on                  = [proxmox_virtual_environment_vm.worker, talos_machine_configuration_apply.controlplane]
  for_each                    = local.workers
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers.machine_configuration
  node                        = proxmox_virtual_environment_vm.worker[each.key].ipv4_addresses[0][0] #first ip of first network interface
  endpoint                    = proxmox_virtual_environment_vm.worker[each.key].ipv4_addresses[0][0] #first ip of first network interface
}

data "talos_cluster_health" "health" {
  depends_on           = [talos_machine_configuration_apply.controlplane, talos_machine_configuration_apply.worker]
  client_configuration = data.talos_client_configuration.homelab.client_configuration
  control_plane_nodes  = [for vm in proxmox_virtual_environment_vm.controlplane : vm.ipv4_addresses[0][0]]
  worker_nodes         = [for vm in proxmox_virtual_environment_vm.worker : vm.ipv4_addresses[0][0]]
  endpoints            = data.talos_client_configuration.homelab.endpoints
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controlplane[keys(local.controlplane)[0]].ip
}
