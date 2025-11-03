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