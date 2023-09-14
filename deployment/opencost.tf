resource "kubernetes_config_map" "opencost_config" {
  metadata {
    name      = "opencost-config"
    namespace = kubernetes_namespace.cost.metadata[0].name
  }

  data = {
    "default.json" = jsonencode(local.ocost_config["opencost"])
  }
}

resource "helm_release" "opencost" {

  name       = "opencost"
  repository = "https://opencost.github.io/opencost-helm-chart"
  chart      = "opencost"
  namespace  = kubernetes_namespace.cost.metadata[0].name
  wait       = true

  set {
    name  = "opencost.ui.enabled"
    value = false
  }

  set {
    name  = "opencost.prometheus.internal.serviceName"
    value = "${helm_release.prometheus.name}-server"
  }

  set {
    name  = "opencost.prometheus.internal.port"
    value = 80
  }

  set {
    name  = "opencost.prometheus.internal.namespaceName"
    value = helm_release.prometheus.namespace
  }

  set {
    name  = "opencost.exporter.extraEnv.CONFIG_PATH"
    value = "/tmp/custom-config"
  }

  set {
    name  = "extraVolumes[0].name"
    value = "custom-configs"
  }

  set {
    name  = "extraVolumes[0].configMap.name"
    value = "opencost-conf"
  }
}

resource "helm_release" "prometheus" {

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.cost.metadata[0].name
  wait       = true

  set {
    name  = "prometheus-pushgateway.enabled"
    value = false
  }

  set {
    name  = "alertmanager.enabled"
    value = false
  }

  set {
    name  = "extraScrapeConfigs"
    value = file("${path.module}/extra_scrape_configs.yaml")
  }
}
