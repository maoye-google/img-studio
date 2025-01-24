locals {
  resource_labels = {
    deployed_by = "cloudbuild"
    repo        = "img-studio"
    terraform   = "true"
  }

  app_name           = var.app_name
  app_container      = var.app_container_name
}

variable "project_id" {
  description = "GCP Project ID"
  default     = null
}

variable "need_dns_setup" {
  description = "Whether DNS Record Setup Should be done as part of automation ?"
  default     = false
}

variable "dns_project_id" {
  description = "GCP Project ID which contains permenant DNS Zone to be used"
  default     = null
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "app_name" {
  description = "Img Studio Application Name"
  default     = "demo"
}

variable "oauth_admin_email" {
  description = "Support Email in Oauth Brand Page"
  default     = "UNKNOWN"
}

variable "app_container_name" {
  type        = string
  description = "Img Studio Container Full Name"
  default = "UNKNOWN"
}

variable "app_tag" {
  description = "Img Studio container tag"
  default     = "latest"
}

variable "customer_domain" {
  description = "Customer Domain Name"
  default     = "imgstudio.mycompany.com"
}