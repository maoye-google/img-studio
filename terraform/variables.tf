locals {
  resource_labels = {
    deployed_by = "cloudbuild"
    repo        = "img-studio"
    terraform   = "true"
  }

  app_name           = var.app_name
  app_container    = "us-central1-docker.pkg.dev/${var.project_id}/docker-repo/img-studio-app:${var.app_tag}"
}

variable "project_id" {
  description = "GCP Project ID"
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

variable "app_tag" {
  description = "Img Studio container tag"
  default     = "latest"
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