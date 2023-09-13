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
          port {
            name           = "http"
            protocol       = "TCP"
            container_port = local.app_container_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ocost" {
  metadata {
    name      = "ocost"
    namespace = kubernetes_namespace.cost.metadata[0].name
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
