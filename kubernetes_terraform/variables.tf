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

variable "extra_talos_filters" {
  type    = list(string)
  default = []
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

variable "kubeapi_extra_sans" {
  type    = list(string)
  default = []
}

variable "deploy_cilium_cni" {
  type    = bool
  default = false
}

variable "cilium_version" {
  type    = string
  default = "1.18.2"
}

variable "deploy_argocd" {
  type    = bool
  default = false
}

variable "argocd_version" {
  type    = string
  default = "v9.0.6"
}

variable "argocd_private_repo" {
  type = object({
    enabled       = bool
    repo_name     = optional(string)
    key_name      = optional(string)
    key_algorithm = optional(string)
    secret_type   = optional(string)
    url           = optional(string)
  })
  default = {
    enabled = false
  }
}

variable "argocd_extra_applications" {
  type = map(object({
    project         = string
    repo_url        = string
    target_revision = string
    path            = string
    value_files     = optional(list(string), [])
    values          = any
  }))
  default = {}
}

variable "argocd_extra_projects" {
  type = map(object({
    description  = string
    source_repos = list(string)
    destinations = list(object({
      server    = string
      namespace = string
    }))
    cluster_resource_whitelist = optional(list(object({
      group = string
      kind  = string
    })), [])
    namespace_resource_whitelist = optional(list(object({
      group = string
      kind  = string
    })), [])
    sync_windows = optional(list(object({
      kind         = string
      schedule     = string
      duration     = string
      applications = list(string)
      manual_sync  = bool
    })))
  }))
  default = {}
}

variable "pod_subnet" {
  type    = string
  default = "10.0.0.0/16"
}

variable "services_subnet" {
  type    = string
  default = "10.1.0.0/16"
}

variable "native_cidr" {
  type    = string
  default = "10.0.0.0/8"
}

variable "default_proxmox_node" {
  type    = string
  default = ""
}

variable "default_user_account" {
  type = object({
    username = string
    password = string
  })
}

variable "default_machine" {
  type    = string
  default = "pc"
}

variable "default_vga" {
  type    = string
  default = "virtio"
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
      vga          = optional(string)
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
      vga          = optional(string)
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
