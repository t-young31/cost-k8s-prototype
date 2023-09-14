locals {
  app_container_port     = 8000
  app_url                = "https://${var.app_fqdn}:${var.https_port}"
  app_internal_url       = "http://${kubernetes_service.ocost.metadata[0].name}.${kubernetes_service.ocost.metadata[0].namespace}.svc.cluster.local"
  app_group_map_filename = "group_map.json"
  app_group_map_path     = "/app/${local.app_group_map_filename}"

  ocost_config = yamldecode(file("${path.module}/../ocost_config.yaml"))
}
