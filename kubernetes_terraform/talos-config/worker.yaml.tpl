machine:
  kubelet:
    extraArgs:
      provider-id: "proxmox://${proxmox_datacenter}/${vm_id}"
      node-ip: "${ipv4_local}"