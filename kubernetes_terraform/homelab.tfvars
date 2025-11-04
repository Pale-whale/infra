cluster_name = "homelab"

talos_version      = "v1.11.3"
kubernetes_version = "v1.34.1"

extra_talos_filters = [
  "i915"
]
talos_schematic = "d3dc673627e9b94c6cd4122289aa52c2484cddb31017ae21b75309846e257d30"

default_gateway    = "10.0.0.254"
dns                = ["10.0.0.254"]
kubeapi_address    = "10.0.0.69"
kubeapi_fqdn       = "kubeapi.palewhale.fr"
kubeapi_extra_sans = ["169.168.1.42"]
pod_subnet         = "10.10.0.0/16"
services_subnet    = "10.20.0.0/16"
native_cidr        = "10.0.0.0/8"
deploy_cilium_cni  = true

default_proxmox_node = "mother-brain"

default_machine             = "q35"
default_controlplane_cpu    = 2
default_controlplane_memory = 4096

default_network_device = {
  bridge = "vmbr1"
  model  = "virtio"
}

default_disk = {
  datastore_id = "local-lvm"
  file_format  = "raw"
  interface    = "scsi1"
  size         = 20
  ssd          = true
  iothread     = true
  discard      = "on"
}

default_cloud_init_datastore = "local-lvm"

/*
  Vm id ranges:
    Control Plane:   110-129
    Generic Workers: 130-149
    Storage Nodes:   150-200
    GPU Workers:     200-219
*/

topology = {
  controlplane = {
    master-card = {
      vm_id = 110
      ip    = "10.50.0.1"
      network_device = {
        mac_address = "bc:24:11:fe:54:91"
      }
      additional_disks = {
        ceph-db = {
          datastore_id = "local-lvm"
          file_format  = "raw"
          interface    = "scsi2"
          size         = 32
          discard      = "on"
          ssd          = true
          iothread     = true
        }
      }
    }
    master-mind = {
      vm_id = 111
      ip    = "10.50.0.2"
      network_device = {
        mac_address = "bc:24:11:3f:2d:2a"
      }
      additional_disks = {
        ceph-db = {
          datastore_id = "local-lvm"
          file_format  = "raw"
          interface    = "scsi2"
          size         = 32
          discard      = "on"
          ssd          = true
          iothread     = true
        }
      }
    }
    master-baiter = {
      vm_id = 112
      ip    = "10.50.0.3"
      network_device = {
        mac_address = "bc:24:11:af:ba:e8"
      }
      additional_disks = {
        ceph-db = {
          datastore_id = "local-lvm"
          file_format  = "raw"
          interface    = "scsi2"
          size         = 32
          discard      = "on"
          ssd          = true
          iothread     = true
        }
      }
    }
  }
  workers = {
    agent-smith = {
      vm_id  = 130
      ip     = "10.60.0.1"
      cpu    = 6
      memory = 16384
      network_device = {
        mac_address = "bc:24:11:96:d2:de"
      }
      usb = [{
        host = "10c4:ea60"
      }]
    }
    agent-milo = {
      vm_id  = 150
      ip     = "10.60.1.1"
      cpu    = 4
      memory = 20480
      network_device = {
        mac_address = "bc:24:11:94:6d:46"
      }
      additional_disks = {
        ceph-disk = {
          datastore_id      = ""
          path_in_datastore = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_4TB_S5STNF0RA06418R"
          file_format       = "raw"
          interface         = "scsi2"
          discard           = "on"
          ssd               = true
          iothread          = true
          size              = 3726
        }
      }
    }
    agent-dewey = {
      vm_id  = 151
      ip     = "10.60.1.2"
      cpu    = 4
      memory = 20480
      network_device = {
        mac_address = "bc:24:11:c4:d7:f1"
      }
      additional_disks = {
        ceph-disk = {
          datastore_id      = ""
          path_in_datastore = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_4TB_S758NX0Y601359W"
          file_format       = "raw"
          interface         = "scsi2"
          discard           = "on"
          ssd               = true
          iothread          = true
          size              = 3726
        }
      }
    }
    agent-rupert = {
      vm_id  = 152
      ip     = "10.60.1.3"
      cpu    = 4
      memory = 20480
      network_device = {
        mac_address = "bc:24:11:be:af:af"
      }
      hostpci = [{
        device = "hostpci0"
        id     = "01:00.0"
        pcie   = true
      }]
    }
    agent-lubrique = {
      vm_id  = 200
      ip     = "10.60.2.1"
      cpu    = 6
      memory = 8192
      vga    = "serial0"
      network_device = {
        mac_address = "bc:24:11:82:d1:2d"
      }
      hostpci = [{
        device = "hostpci0"
        id     = "0000:00:02"
        pcie   = true
      }]
    }
  }
}
