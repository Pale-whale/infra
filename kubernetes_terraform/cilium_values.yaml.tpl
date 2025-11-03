autoDirectNodeRoutes: true
annotateK8sNode: true
routingMode: 'native'
bgpControlPlane:
  enabled: true
bpfClockProbe: true
bpf:
  hostLegacyRouting: false
  masquerade: true
  preallocateMaps: true
  tproxy: false
cgroup:
  autoMount:
    enabled: false
  hostRoot: '/sys/fs/cgroup'
disableEnvoyVersionCheck: true
k8sServiceHost: 10.0.0.69
k8sServicePort: 6443
hubble:
  enabled: false
  ui:
    enabled: false
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
serviceAccounts:
  nodeinit:
    enabled: true
tolerations:
  - operator: Exists
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
    operator: Exists
  - effect: NoSchedule
    key: node.cilium.io/agent-not-ready
    operator: Exists
