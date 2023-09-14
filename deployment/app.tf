resource "kubernetes_deployment" "ocost" {
  metadata {
    name      = "ocost"
    namespace = kubernetes_namespace.cost.metadata[0].name
    labels = {
      app = "ocost"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ocost"
      }
    }

    template {
      metadata {
        labels = {
          app = "ocost"
        }
      }

      spec {
        container {
          name              = "ocost"
          image             = var.app_image
          image_pull_policy = "IfNotPresent"
          env {
            name  = "PORT"
            value = local.app_container_port
          }
          env {
            name  = "GROUP_MAP_PATH"
            value = local.app_group_map_path
          }
          env {
            name  = "OPENCOST_URL"
            value = "http://${helm_release.opencost.name}.${helm_release.opencost.namespace}.svc.cluster.local:9003"
          }
          port {
            name           = "http"
            protocol       = "TCP"
            container_port = local.app_container_port
          }
          volume_mount {
            name       = "group-map"
            mount_path = local.app_group_map_path
            read_only  = true
            sub_path   = local.app_group_map_filename
          }
        }
        volume {
          name = "group-map"
          secret {
            secret_name = kubernetes_secret.ocost_group_map.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ocost" {
  metadata {
    name      = "ocost"
    namespace = kubernetes_deployment.ocost.metadata[0].name
    labels = {
      app = "ocost"
    }
  }

  spec {
    selector = {
      app = "ocost"
    }

    port {
      port        = 80
      target_port = local.app_container_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_secret" "ocost_group_map" {
  metadata {
    name      = "ocost-group-map"
    namespace = kubernetes_namespace.cost.metadata[0].name
  }

  data = {
    "group_map.json" = jsonencode(local.ocost_config["groups"])
  }

  type = "Opaque"
}
