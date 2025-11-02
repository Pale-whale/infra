resource "helm_release" "cilium" {
  depends_on = [talos_machine_bootstrap.bootstrap]

  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_version

  values = [templatefile("${path.module}/cilium_values.yaml.tpl", {
    native_cidr = var.pod_subnet
  })]
}
