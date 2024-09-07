resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = var.argocd_namespace
  create_namespace = true
  lifecycle {
    prevent_destroy = false
  }
}

locals {
  argocd_deployed = helm_release.argocd.status == "deployed" ? 1 : 0
}

resource "kubectl_manifest" "app-of-apps" {
  count     = local.argocd_deployed
  yaml_body = file(var.parent_app_path)
}



