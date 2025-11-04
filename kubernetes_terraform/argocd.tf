resource "tls_private_key" "argocd" {
  count = var.deploy_argocd && var.argocd_private_repo.enabled ? 1 : 0

  algorithm = var.argocd_private_repo.key_algorithm
}

data "tls_public_key" "argocd" {
  count = var.deploy_argocd && var.argocd_private_repo.enabled ? 1 : 0

  private_key_pem = tls_private_key.argocd.private_key_pem
}

resource "github_user_ssh_key" "argocd" {
  count = var.deploy_argocd && var.argocd_private_repo.enabled ? 1 : 0

  title = var.argocd_private_repo.key_name
  key   = data.tls_public_key.argocd.public_key_openssh
}

resource "helm_release" "argocd" {
  depends_on = [talos_cluster_health.health]
  count      = var.deploy_argocd ? 1 : 0

  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd"
  version          = var.argocd_version
  create_namespace = true

  values = [templatefile("${path.module}/values/argocd.yaml.tpl", {
    extra_applications = var.argocd_extra_applications
    extra_projects     = var.argocd_extra_projects
  })]
}

resource "kubernetes_secret" "argocd_repo" {
  depends_on = [helm_release.argocd]
  count      = var.deploy_argocd && var.argocd_private_repo.enabled ? 1 : 0

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
    sshPrivateKey = tls_private_key.argocd.private_key_pem
  }

  type = "Opaque"
}
