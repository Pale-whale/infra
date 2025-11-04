data "talos_cluster_health" "kubeapi_up" {
  depends_on = [talos_machine_bootstrap.bootstrap]
  count      = var.deploy_cilium_cni ? 1 : 0

  client_configuration   = data.talos_client_configuration.homelab.client_configuration
  control_plane_nodes    = [for n in local.controlplane : n.ip]
  worker_nodes           = [for n in local.workers : n.ip]
  endpoints              = data.talos_client_configuration.homelab.endpoints
  skip_kubernetes_checks = true
}

resource "helm_release" "cilium" {
  depends_on = [data.talos_cluster_health.kubeapi_up]
  count      = var.deploy_cilium_cni ? 1 : 0

  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_version

  values = [templatefile("${path.module}/values/cilium.yaml.tpl", {
    native_cidr = var.pod_subnet
  })]
}
