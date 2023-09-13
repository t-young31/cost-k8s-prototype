variable "namespace" {
  type        = string
  description = "K8s namespace into which resources are going to be deployed"
}

variable "aad_tenant_id" {
  type        = string
  description = "Azure AD tenant ID. See the README for further guidance"
}

variable "aad_application_id" {
  type        = string
  description = "Azure AD application ID. See the README for further guidance"
}

variable "aad_application_secret" {
  type        = string
  description = "Azure AD application secret. See the README for further guidance"
}

variable "app_fqdn" {
  type        = string
  description = "Fully qualified domain name of the app to deploy"
}

variable "https_port" {
  type        = string
  description = "HTTPS port for ingress. For local development it should be the loadbalancers port"
}
