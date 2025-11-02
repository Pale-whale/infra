data "talos_cluster_health" "api_available" {
  depends_on = [talos_machine_configuration_apply.controlplane, talos_machine_configuration_apply.worker]

  client_configuration   = data.talos_client_configuration.homelab.client_configuration
  control_plane_nodes    = [for n in local.controlplane : n.ip]
  endpoints              = data.talos_client_configuration.homelab.endpoints
  skip_kubernetes_checks = true
}

resource "helm_release" "cilium" {
  depends_on = [data.talos_cluster_health.api_available]

  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_version

  values = [templatefile("${path.module}/cilium_values.yaml.tpl", {
    native_cidr = var.pod_subnet
  })]
}
