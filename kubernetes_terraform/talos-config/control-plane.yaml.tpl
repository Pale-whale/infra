machine:
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
    enabled: true
    manifests:
      - https://raw.githubusercontent.com/sergelogvinov/proxmox-cloud-controller-manager/main/docs/deploy/cloud-controller-manager.yml
      - https://raw.githubusercontent.com/sergelogvinov/proxmox-csi-plugin/main/docs/deploy/proxmox-csi-plugin.yml
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