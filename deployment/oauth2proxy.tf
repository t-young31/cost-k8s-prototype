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
    name  = "config.clientID"
    value = var.aad_application_id
  }

  set {
    name  = "config.clientSecret"
    value = var.aad_application_secret
  }

  set {
    name  = "service.portNumber"
    value = 80
  }

  set {
    name = "config.configFile"
    value = templatefile("${path.module}/oauth2proxy.template.cfg",
      {
        oidc_issuer_url = "https://login.microsoftonline.com/${var.aad_tenant_id}/v2.0"
        redirect_url    = "${local.app_url}/oauth2/callback"
        app_url         = local.app_internal_url
      }
    )
  }
}

resource "kubernetes_ingress_v1" "oauth2proxy" {
  metadata {
    name      = "oauth2-proxy"
    namespace = helm_release.oauth2proxy.namespace
  }

  spec {
    rule {
      host = var.app_fqdn
      http {
        path {
          path      = "/"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = helm_release.oauth2proxy.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "random_password" "cookie_secret" {
  length           = 32
  override_special = "-_"
}
