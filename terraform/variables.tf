locals {
  resource_labels = merge(var.resource_labels, {
    deployed_by = "cloudbuild"
    repo        = "img-studio"
    terraform   = "true"
    }
  )

  app_name           = "demo"
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

variable "app_tag" {
  description = "Img Studio container tag"
  default     = "latest"
}

variable "gemini_model" {
  description = "Default Gemini Model Name for Text Generation"
  default     = "gemini-1.5-flash-001"
}

variable "gemini_segment_model" {
  description = "Default Gemini Segmentation Model Name for Image Segmentation"
  default     = "image-segmentation-001"
}

variable "gemini_image_edit_enabled" {
  description = "Whether the target project has been whitelisted for Image Edit Feature"
  default     = "true" # false
}

variable "gemini_image_edit_enabled" {
  description = "Whether the target project has been whitelisted for Image Edit Feature"
  default     = "true" # false
}

variable "output_bucket_name" {
  description = "Default GCS Bucket Name to store output files"
  default     = "${locals.app_name}-imgstudio-output"
}

variable "output_bucket_name" {
  description = "Default GCS Bucket Name to store output files"
  default     = "${locals.app_name}-imgstudio-library"
}

variable "config_bucket_name" {
  description = "Default GCS Bucket Name to store JSON configuration files"
  default     = "${locals.app_name}-imgstudio-export-config"
}




      env {
        name  = "NEXT_PUBLIC_EDIT_ENABLED"
        value = google_pubsub_topic.rcs_topic.name
      }
      env {
        name  = "NEXT_PUBLIC_PRINCIPAL_TO_USER_FILTERS"
        value = google_pubsub_topic.rcs_topic.name
      }
      env {
        name  = "NEXT_PUBLIC_OUTPUT_BUCKET"
        value = google_pubsub_topic.rcs_topic.name
      }
      env {
        name  = "NEXT_PUBLIC_TEAM_BUCKET"
        value = google_pubsub_topic.rcs_topic.name
      }
      env {
        name  = "NEXT_PUBLIC_EXPORT_FIELDS_OPTIONS_URI"
        value = google_pubsub_topic.rcs_topic.name
      }