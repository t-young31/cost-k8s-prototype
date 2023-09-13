locals {
  app_container_port = 8000
  app_url            = "https://${var.app_fqdn}:${var.https_port}"
  app_internal_url   = "http://${kubernetes_service.ocost.metadata[0].name}.${kubernetes_service.ocost.metadata[0].namespace}.svc.cluster.local"
}
