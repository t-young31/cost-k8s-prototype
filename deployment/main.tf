resource "kubernetes_namespace" "cost" {
  metadata {
    name = var.namespace
  }
}
