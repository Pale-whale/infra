autoDirectNodeRoutes: true
annotateK8sNode: true
routingMode: 'native'
enableIPv4Masquerade: true
bgpControlPlane:
  enabled: true
bpfClockProbe: true
bpf:
  hostLegacyRouting: true
  masquerade: true
  preallocateMaps: true
  tproxy: false
cgroup:
  autoMount:
    enabled: false
  hostRoot: '/sys/fs/cgroup'
k8sServiceHost: localhost
k8sServicePort: 7445
hubble:
  enabled: true
  ui:
    enabled: true
  relay:
    enabled: true
installNoConntrackIptablesRules: true
ipam:
  mode: kubernetes
ipv4NativeRoutingCIDR: ${native_cidr}
kubeProxyReplacement: "true"
loadBalancer:
  algorithm: maglev
  mode: hybrid
localRedirectPolicy: true
localRedirectPolicies:
  enabled: true
maglev:
  tableSize: 4093
  hashSeed: 'JAeU+bGYbg1OJFJd'
operator:
  replicas: 2
  rollOutPods: true
securityContext:
  capabilities:
    ciliumAgent:
      - CHOWN
      - KILL
      - NET_ADMIN
      - NET_RAW
      - IPC_LOCK
      - SYS_ADMIN
      - SYS_RESOURCE
      - DAC_OVERRIDE
      - FOWNER
      - SETGID
      - SETUID
    cleanCiliumState:
      - NET_ADMIN
      - SYS_ADMIN
      - SYS_RESOURCE
tolerations:
  - operator: Exists
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
    operator: Exists
  - effect: NoSchedule
    key: node.cilium.io/agent-not-ready
    operator: Exists
