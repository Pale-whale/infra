machine:
  kubelet:
    extraArgs:
      cloud-provider: external

  nodeTaints:
    node.cilium.io/agent-not-ready: 'true:NoSchedule'

  kernel:
    modules:
      - name: br_netfilter
        parameters:
          - nf_conntrack_max=131072

  sysctls:
    net.bridge.bridge-nf-call-ip6tables: "1"
    net.bridge.bridge-nf-call-iptables: "1"
    net.ipv4.ip_forward: "1"


  features:
    kubePrism:
      enabled: true
      port: 7445
    hostDNS:
      enabled: true
      forwardKubeDNSToHost: false
      resolveMemberNames: true

%{ if deploy_cilium_cni ~}
cluster:
  network:
    cni:
      name: none
  proxy:
    disabled: true
%{ endif ~}