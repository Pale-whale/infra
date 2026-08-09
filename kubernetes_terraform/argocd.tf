resource "tls_private_key" "argocd" {
  # Bootstrap-only: the tls provider has no import support, so any apply would
  # generate a NEW keypair and rotate ArgoCD's git SSH credentials.
  count = var.deploy_argocd && var.argocd_private_repo.enabled && var.bootstrap_phase ? 1 : 0

  algorithm = var.argocd_private_repo.key_algorithm
}

resource "github_user_ssh_key" "argocd" {
  # Bootstrap-only: follows tls_private_key.argocd above.
  count = var.deploy_argocd && var.argocd_private_repo.enabled && var.bootstrap_phase ? 1 : 0

  title = var.argocd_private_repo.key_name
  key   = tls_private_key.argocd[0].public_key_openssh
}

resource "helm_release" "argocd_bootstrap" {
  # Phase 1 of the two-phase install: it exists purely so the argo-cd CRDs are
  # established before argocd_extra_objects creates AppProject/Application CRs in
  # the same chart (argo-cd ships its CRDs as ordinary templates/crds/, not in a
  # crds/ dir, so a single-pass install races establishment). It shares the
  # argocd/argocd release name with argocd_extra_objects, which owns the release
  # in state -- so this must not exist outside a greenfield build.
  depends_on = [data.talos_cluster_health.health]
  count      = var.deploy_argocd && var.bootstrap_phase ? 1 : 0

  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version
  create_namespace = true
  upgrade_install  = true
}

resource "helm_release" "argocd_extra_objects" {
  depends_on = [helm_release.argocd_bootstrap]
  count      = var.deploy_argocd ? 1 : 0

  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version
  create_namespace = true
  upgrade_install  = true

  values = [templatefile("${path.module}/values/argocd.yaml.tpl", {
    extra_applications = var.argocd_extra_applications
    extra_projects     = var.argocd_extra_projects
  })]

  # This address owns the live argocd/argocd release (imported). Same reasoning as
  # helm_release.cilium: the provider does not read repository/values/upgrade_install
  # back on import and records the version as "9.0.6" against the config's "v9.0.6",
  # so an unfrozen plan shows a permanent phantom update. Re-applying the values would
  # also rewrite the app-of-apps root, whose Applications carry
  # resources-finalizer.argocd.argoproj.io with prune enabled -- removing one prunes
  # the real workloads. Freeze it.
  lifecycle {
    # NOT `all`: that also freezes `repository` at the null the import leaves behind,
    # and the provider then cannot resolve the chart ("non-absolute URLs should be in
    # form of repo_name/path_to_chart"). Freeze only what actually drifts.
    ignore_changes = [version, values, create_namespace, upgrade_install]

    prevent_destroy = true
  }
}

resource "kubernetes_secret" "argocd_repo" {
  # Bootstrap-only: carries tls_private_key.argocd's private key.
  depends_on = [helm_release.argocd_bootstrap]
  count      = var.deploy_argocd && var.argocd_private_repo.enabled && var.bootstrap_phase ? 1 : 0

  metadata {
    name      = var.argocd_private_repo.repo_name
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/managed-by"   = "terraform-bootstrap"
      "argocd.argoproj.io/secret-type" = var.argocd_private_repo.secret_type
    }
  }

  data = {
    type          = "git"
    url           = var.argocd_private_repo.url
    sshPrivateKey = tls_private_key.argocd[0].private_key_openssh
  }

  type = "Opaque"
}
