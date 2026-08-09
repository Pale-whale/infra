data "talos_cluster_health" "kubeapi_up" {
  depends_on = [talos_machine_bootstrap.bootstrap]
  # Bootstrap-only, same as the other one-shot resources. Holding this in state is
  # actively unsafe: `terraform import` records neither `repository` nor `values`, so
  # a plan shows a harmless-looking repository diff while an apply would run
  # `helm upgrade` with values=null -- i.e. re-render the chart with pure defaults over
  # what ArgoCD manages. ignore_changes hides that rather than preventing it.
  # ArgoCD owns these workloads now; Terraform only needs them for a greenfield build.
  count = var.deploy_cilium_cni && var.bootstrap_phase ? 1 : 0

  client_configuration   = data.talos_client_configuration.homelab.client_configuration
  control_plane_nodes    = [for n in local.controlplane : n.ip]
  worker_nodes           = [for n in local.workers : n.ip]
  endpoints              = data.talos_client_configuration.homelab.endpoints
  skip_kubernetes_checks = true
}

resource "helm_release" "cilium" {
  depends_on = [data.talos_cluster_health.kubeapi_up]
  # Bootstrap-only, same as the other one-shot resources. Holding this in state is
  # actively unsafe: `terraform import` records neither `repository` nor `values`, so
  # a plan shows a harmless-looking repository diff while an apply would run
  # `helm upgrade` with values=null -- i.e. re-render the chart with pure defaults over
  # what ArgoCD manages. ignore_changes hides that rather than preventing it.
  # ArgoCD owns these workloads now; Terraform only needs them for a greenfield build.
  count = var.deploy_cilium_cni && var.bootstrap_phase ? 1 : 0

  name            = "cilium"
  namespace       = "kube-system"
  repository      = "https://helm.cilium.io/"
  chart           = "cilium"
  version         = var.cilium_version
  upgrade_install = true

  values = [templatefile("${path.module}/values/cilium.yaml.tpl", {
    native_cidr = var.pod_subnet
  })]

  # Imported from the live release. The helm provider does not read back
  # repository/values/create_namespace/upgrade_install on import, and it records the
  # chart version without the leading "v", so every plan would otherwise show a bogus
  # update. More importantly ArgoCD owns these workloads now: the release metadata is
  # a frozen bootstrap artifact (cilium 1.18.2 rev1, argo-cd 9.0.6 rev5) while the
  # running pods are far newer, applied by ArgoCD as plain manifests that Helm never
  # saw. Freezing keeps a future version bump here from stamping an older chart over
  # what ArgoCD manages, while a greenfield create still uses the config.

}
