resource "helm_release" "cilium" {
  depends_on = [talos_machine_configuration_apply.controlplane, talos_machine_configuration_apply.worker]

  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_version

  values = [templatefile("${path.module}/cilium_values.yaml.tpl", {
    kubeapi_address = var.kubeapi_address
    native_cidr     = var.native_cidr
  })]
}
