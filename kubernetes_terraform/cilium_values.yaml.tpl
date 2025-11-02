autoDirectNodeRoutes: true
annotateK8sNode: true
routingMode: 'native'
bgpControlPlane:
  enabled: true
bpfClockProbe: true
bpf:
  hostLegacyRouting: false
  masquerade: false
  preallocateMaps: true
  tproxy: true
disableEnvoyVersionCheck: true
k8sServiceHost: ${kubeapi_address}
k8sServicePort: 6443
hubble:
  enabled: false
  ui:
    enabled: false
installNoConntrackIptablesRules: false
ipam:
  mode: kubernetes
ipv4NativeRoutingCIDR: ${native_cidr}
kubeProxyReplacement: true
loadBalancer:
  algorithm: maglev
  mode: hybrid
localRedirectPolicy: false
maglev:
  tableSize: 4093
  hashSeed: 'JAeU+bGYbg1OJFJd'
operator:
  replicas: 2
  rollOutPods: true
serviceAccounts:
  nodeinit:
    enabled: true
sessionAffinity: true
tolerations:
  - operator: Exists
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
    operator: Exists
  - effect: NoSchedule
    key: node.cilium.io/agent-not-ready
    operator: Exists
