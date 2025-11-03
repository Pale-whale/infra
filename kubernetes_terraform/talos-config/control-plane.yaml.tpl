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

  network:
    hostname: ${hostname}
    interfaces:
      - interface: eth0
        dhcp: false
        addresses:
          - ${ipv4_local}/${network_ip_prefix}
        routes:
          - network: 0.0.0.0/0
            gateway: ${network_gateway}
  

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