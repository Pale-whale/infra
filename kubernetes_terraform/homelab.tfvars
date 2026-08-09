cluster_name = "homelab"

# Live: nodes report Talos v1.13.0 (upgraded in place since install).
talos_version = "v1.13.0"
# Live: kubelet and all control-plane components run v1.35.4. This is baked into
# the machine config as pinned image tags -- v1.34.1 here meant any
# machine_configuration_apply would have downgraded Kubernetes.
kubernetes_version = "v1.35.4"

extra_talos_filters = [
  "i915"
]
talos_schematic = "d3dc673627e9b94c6cd4122289aa52c2484cddb31017ae21b75309846e257d30"

default_gateway    = "10.0.0.254"
dns                = ["10.0.0.254"]
kubeapi_address    = "10.0.0.69"
kubeapi_fqdn       = "kubeapi.palewhale.fr"
kubeapi_extra_sans = ["192.168.1.42"]
pod_subnet         = "10.10.0.0/16"
services_subnet    = "172.16.0.0/16"
native_cidr        = "10.0.0.0/8"
deploy_cilium_cni  = true
deploy_argocd      = true

default_proxmox_node = "mother-brain"

default_machine = "q35"
# Codified from live: every VM reports 6 cores; the masters run 6144 MiB.
default_controlplane_cpu    = 6
default_controlplane_memory = 6144

# Codified from the imported state. The VMs sit on vmbr0 -- the VLAN-aware bridge
# that owns the physical uplink (enp134s0f0np0) -- tagged into VLAN 30. The previous
# value, vmbr1, is an isolated internal bridge with no ports at 192.168.88.1/24:
# applying it would have moved every node onto a network with no uplink.
default_network_device = {
  bridge  = "vmbr0"
  model   = "virtio"
  vlan_id = 30
}

# Boot disks live on the nvme-vm datastore, not local-lvm, and carry an explicit
# cache/aio. Codified from the imported state.
default_disk = {
  datastore_id = "nvme-vm"
  file_format  = "raw"
  interface    = "scsi1"
  size         = 20
  ssd          = true
  iothread     = true
  discard      = "on"
  cache        = "none"
  aio          = "io_uring"
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
    }
    master-mind = {
      vm_id = 111
      ip    = "10.50.0.2"
      network_device = {
        mac_address = "bc:24:11:3f:2d:2a"
      }
    }
    master-baiter = {
      vm_id = 112
      ip    = "10.50.0.3"
      network_device = {
        mac_address = "bc:24:11:af:ba:e8"
      }
    }
  }
  workers = {
    agent-smith = {
      vm_id  = 130
      ip     = "10.60.0.1"
      cpu    = 6
      memory = 16384
      disk = {
        size = 42
      }
      network_device = {
        mac_address = "bc:24:11:96:d2:de"
      }
      usb = [{
        host = "3-2" # live: Proxmox stores the bus-port form, not vendor:product
      }]
    }
    agent-milo = {
      vm_id  = 150
      ip     = "10.60.1.1"
      cpu    = 6
      memory = 24576
      disk = {
        size = 42
      }
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
          cache             = "writeback"
          aio               = "io_uring"
          size              = 3726
        }
        ceph-scsi3 = {
          datastore_id      = ""
          path_in_datastore = "/dev/disk/by-id/ata-WD_Red_SA500_2.5_4TB_2552Q8D01234"
          file_format       = "raw"
          interface         = "scsi3"
          discard           = "on"
          ssd               = true
          iothread          = true
          cache             = "writeback"
          aio               = "io_uring"
          size              = 3726
        }
        ceph-scsi4 = {
          datastore_id      = ""
          path_in_datastore = "/dev/disk/by-id/ata-WD_Red_SA500_2.5_4TB_2538PRD00103"
          file_format       = "raw"
          interface         = "scsi4"
          discard           = "on"
          ssd               = true
          iothread          = true
          cache             = "writeback"
          aio               = "io_uring"
          size              = 3726
        }
      }
    }
    agent-dewey = {
      vm_id  = 151
      ip     = "10.60.1.2"
      cpu    = 6
      memory = 24576
      disk = {
        size = 42
      }
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
          cache             = "writeback"
          aio               = "io_uring"
          size              = 3726
        }
        ceph-scsi3 = {
          datastore_id      = ""
          path_in_datastore = "/dev/disk/by-id/ata-WD_Red_SA500_2.5_4TB_25445KD00296"
          file_format       = "raw"
          interface         = "scsi3"
          discard           = "on"
          ssd               = true
          iothread          = true
          cache             = "writeback"
          aio               = "io_uring"
          size              = 3726
        }
        ceph-scsi4 = {
          datastore_id      = ""
          path_in_datastore = "/dev/disk/by-id/ata-WD_Red_SA500_2.5_4TB_2538PRD00091"
          file_format       = "raw"
          interface         = "scsi4"
          discard           = "on"
          ssd               = true
          iothread          = true
          cache             = "writeback"
          aio               = "io_uring"
          size              = 3726
        }
      }
    }
    agent-rupert = {
      vm_id  = 152
      ip     = "10.60.1.3"
      cpu    = 6
      memory = 20480
      disk = {
        size = 42
      }
      network_device = {
        mac_address = "bc:24:11:be:af:af"
      }
      additional_disks = {
        ceph-scsi2 = {
          datastore_id      = ""
          path_in_datastore = "/dev/disk/by-id/ata-WD_Red_SA500_2.5_4TB_2538PRD00245"
          file_format       = "raw"
          interface         = "scsi2"
          discard           = "on"
          ssd               = true
          iothread          = true
          cache             = "writeback"
          aio               = "io_uring"
          size              = 3726
        }
      }
      hostpci = [{
        device = "hostpci0"
        id     = "0000:87:00.0" # live PCI address of the NVMe
        pcie   = true
      }]
    }
    agent-lubrique = {
      vm_id  = 200
      ip     = "10.60.2.1"
      cpu    = 6
      memory = 16384
      disk = {
        size = 42
      }
      vga = "serial0"
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

argocd_private_repo = {
  enabled       = true
  repo_name     = "github"
  key_name      = "homelab"
  key_algorithm = "ED25519"
  secret_type   = "repo-creds"
  url           = "git@github.com"
}

argocd_extra_projects = {
  infra = {
    description  = "Holds the homelab infra"
    source_repos = ["*"]
    destinations = [{
      namespace = "*"
      server    = "https://kubernetes.default.svc"
    }]
    cluster_resource_whitelist = [{
      group = "*"
      kind  = "*"
    }]
    namespace_resource_whitelist = [{
      group = "*"
      kind  = "*"
    }]
    sync_windows = [{
      kind         = "allow"
      schedule     = "30 4 * * SAT,SUN"
      duration     = "5h"
      applications = ["*"]
      manual_sync  = true
    }]
  }
}

argocd_extra_applications = {
  root = {
    project         = "infra"
    repo_url        = "git@github.com:Pale-Whale/infra.git"
    target_revision = "HEAD"
    path            = "k8s/root_app"
    value_files     = []
    values = {
      repository = {
        url = "git@github.com:pale-whale/infra.git"
      }
    }
  }
}
