variable "cluster_name" {
  type = string
}

variable "talos_version" {
  type    = string
  default = "v1.11.3"
}

variable "talos_schematic" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "v1.34.1"
}

variable "default_gateway" {
  type = string
}

variable "dns" {
  type    = list(string)
  default = ["1.1.1.1"]
}

variable "kubeapi_address" {
  type = string
}

variable "kubeapi_fqdn" {
  type    = string
  default = "kubeapi.local"
}

variable "default_proxmox_node" {
  type    = string
  default = ""
}

variable "default_machine" {
  type    = string
  default = "pc"
}

variable "default_controlplane_cpu" {
  type    = number
  default = 2
}

variable "default_controlplane_memory" {
  type    = number
  default = 4096
}

variable "default_workers_cpu" {
  type    = number
  default = 2
}

variable "default_workers_memory" {
  type    = number
  default = 2048
}

variable "default_network_device" {
  type = object({
    bridge       = string
    disconnected = optional(bool)
    enabled      = optional(bool)
    firewall     = optional(bool)
    mac_address  = optional(string)
    model        = optional(string)
    mtu          = optional(number)
    vlan_id      = optional(number)
    trunks       = optional(string)
  })
  default = {
    bridge = "vmbr0"
  }
}

variable "default_disk" {
  type = object({
    datastore_id = optional(string)
    file_format  = optional(string)
    interface    = optional(string)
    size         = optional(number)
    ssd          = optional(bool)
    discard      = optional(string)
    iothread     = optional(bool)
  })
  default = {}
}

variable "default_cloud_init_datastore" {
  type    = string
  default = "local-lvm"
}

variable "topology" {
  type = object({
    controlplane = map(object({
      vm_id        = number
      ip           = string
      machine      = optional(string)
      proxmox_node = optional(string)
      cpu          = optional(number)
      memory       = optional(number)
      network_device = optional(object({
        bridge       = optional(string)
        disconnected = optional(bool)
        enabled      = optional(bool)
        firewall     = optional(bool)
        mac_address  = optional(string)
        model        = optional(string)
        mtu          = optional(number)
        vlan_id      = optional(number)
        trunks       = optional(string)
      }), {})
      disk = optional(object({
        datastore_id = optional(string)
        file_format  = optional(string)
        interface    = optional(string)
        size         = optional(number)
        ssd          = optional(bool)
        discard      = optional(string)
        iothread     = optional(bool)
      }), {})
      additional_disks = optional(map(object({
        datastore_id      = optional(string)
        file_format       = optional(string)
        interface         = optional(string)
        size              = optional(number)
        discard           = optional(string)
        iothread          = optional(bool)
        ssd               = optional(bool)
        import_from       = optional(string)
        path_in_datastore = optional(string)
      })), {})
    }))
    workers = map(object({
      vm_id        = number
      ip           = string
      machine      = optional(string)
      proxmox_node = optional(string)
      cpu          = optional(number)
      memory       = optional(number)
      network_device = optional(object({
        bridge       = optional(string)
        disconnected = optional(bool)
        enabled      = optional(bool)
        firewall     = optional(bool)
        mac_address  = optional(string)
        model        = optional(string)
        mtu          = optional(number)
        vlan_id      = optional(number)
        trunks       = optional(string)
      }), {})
      disk = optional(object({
        datastore_id = optional(string)
        file_format  = optional(string)
        interface    = optional(string)
        size         = optional(number)
        ssd          = optional(bool)
        discard      = optional(string)
        iothread     = optional(bool)
      }), {})
      additional_disks = optional(map(object({
        datastore_id      = optional(string)
        file_format       = optional(string)
        interface         = optional(string)
        size              = optional(number)
        discard           = optional(string)
        iothread          = optional(bool)
        ssd               = optional(bool)
        import_from       = optional(string)
        path_in_datastore = optional(string)
      })), {})
      usb = optional(list(object({
        host = optional(string)
        usb3 = optional(bool)
      })), [])
      hostpci = optional(list(object({
        device = optional(string)
        id     = optional(string)
        pcie   = optional(bool)
      })), [])
    }))
  })
}
