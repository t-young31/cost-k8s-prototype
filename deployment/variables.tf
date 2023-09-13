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
