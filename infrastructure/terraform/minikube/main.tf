resource "helm_release" "argocd" {
  chart = "argo-cd"
  name  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace = "argocd"
  create_namespace = true
  lifecycle {
    prevent_destroy = false
  }
}

locals {
  argocd_deployed = helm_release.argocd.status == "deployed" ? 1:0
}

resource "kubectl_manifest" "app-of-apps" {
  count = local.argocd_deployed
  yaml_body = file(var.parent_app_path)
}

resource "null_resource" "sync_argocd_app" {
  count = local.argocd_deployed

  provisioner "local-exec" {
    command = <<EOT
      kubectl port-forward svc/argocd-server -n argocd 8080:80 &
      sleep 10
      PASSWORD=$(kubectl get secrets/argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d)
      argocd login localhost:8080 --username admin --password $PASSWORD --insecure
      argocd app sync app-of-apps
    EOT
  }

  depends_on = [kubectl_manifest.app-of-apps]
}



