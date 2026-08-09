machine:
  kubelet:
    extraArgs:
      provider-id: "proxmox://${proxmox_datacenter}/${vm_id}"
      node-ip: "${ipv4_local}"
  certSANs:
    - ${kubeapi_fqdn}
    - ${kubeapi_address}
%{ for san in extra_sans ~}
    - ${san}
%{ endfor ~}

  features:
    kubernetesTalosAPIAccess:
      enabled: true
      allowedRoles:
        - os:reader
      allowedKubernetesNamespaces:
        - kube-system

cluster:
  externalCloudProvider:
    # No manifests here on purpose. Talos used to bootstrap the Proxmox CCM and CSI
    # plugin from upstream URLs, but both are ArgoCD applications now
    # (k8s/applications/git/proxmox-ccm.yaml, proxmox-csi.yaml). Leaving them here
    # means Talos re-applies upstream manifests over what ArgoCD manages, and pins
    # them to whatever main happens to be that day.
    enabled: true
  network:
    podSubnets:
      - ${pod_subnet}
    serviceSubnets:
      - ${services_subnet}
  allowSchedulingOnControlPlanes: false
  apiServer:
    certSANs:
      - ${kubeapi_fqdn}
      - ${kubeapi_address}
%{ for san in extra_sans ~}
      - ${san}
%{ endfor ~}
