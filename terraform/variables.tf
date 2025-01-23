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

variable "app_container_name" {
  type        = string
  description = "Img Studio Application Name"
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

variable "gemini_model" {
  description = "Default Gemini Model Name for Text Generation"
  default     = "gemini-1.5-flash-001"
}

variable "gemini_edit_model" {
  description = "Default Gemini Model Name for Image Generation and Edit"
  default     = "gemini-3.0-generate-001"
}

variable "gemini_segment_model" {
  description = "Default Gemini Segmentation Model Name for Image Segmentation"
  default     = "image-segmentation-001"
}

variable "gemini_image_edit_enabled" {
  description = "Whether the target project has been whitelisted for Image Edit Feature"
  default     = "true" # false
}