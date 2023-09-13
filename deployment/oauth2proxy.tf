resource "helm_release" "oauth2proxy" {

  name       = "oauth2-proxy"
  repository = "https://oauth2-proxy.github.io/manifests"
  chart      = "oauth2-proxy"
  namespace  = kubernetes_namespace.cost.metadata[0].name
  wait       = true

  set {
    name  = "config.cookieSecret"
    value = random_password.cookie_secret.result
  }

  set {
    name = "config.configFile"
    value = templatefile("${path.module}/oauth2proxy.template.cfg",
      {
        oidc_issuer_url = "https://login.microsoftonline.com/${var.aad_tenant_id}/v2.0"
        redirect_url    = "https://${var.app_fqdn}:${var.https_port}/oauth2/callback"
        client_id       = var.aad_application_id
        client_secret   = var.aad_application_secret
      }
    )
  }
}

resource "random_password" "cookie_secret" {
  length           = 32
  override_special = "-_"
}
