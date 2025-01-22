# Img Studio Cloud Run service
resource "google_cloud_run_v2_service" "img_studio_service" {
  name     = local.app_name
  location = var.region
  deletion_protection = false

  template {
    service_account = google_service_account.app_sa.email
    containers {
      image = local.app_container
      env {
        name  = "NEXT_PUBLIC_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "NEXT_PUBLIC_VERTEX_API_LOCATION"
        value = var.region
      }
      env {
        name  = "NEXT_PUBLIC_GCS_BUCKET_LOCATION"
        value = var.region
      }
      env {
        name  = "NEXT_PUBLIC_GEMINI_MODEL"
        value = var.gemini_model
      }
      env {
        name  = "NEXT_PUBLIC_SEG_MODEL"
        value = var.gemini_segment_model
      }
      env {
        name  = "NEXT_PUBLIC_EDIT_ENABLED"
        value = var.gemini_image_edit_enabled
      }
      env {
        name  = "NEXT_PUBLIC_PRINCIPAL_TO_USER_FILTERS"
        value = ",@maoye.altostrat.com"
      }
      env {
        name  = "NEXT_PUBLIC_OUTPUT_BUCKET"
        value = google_storage_bucket.output_bucket.name
      }
      env {
        name  = "NEXT_PUBLIC_TEAM_BUCKET"
        value = google_storage_bucket.team_bucket.name
      }
      env {
        name  = "NEXT_PUBLIC_EXPORT_FIELDS_OPTIONS_URI"
        value = "gs://${google_storage_bucket_object.uploaded_config.bucket}/${google_storage_bucket_object.uploaded_config.name}"
      }
    }
    annotations = {
      "autoscaling.knative.dev/minScale" = "1"
      "autoscaling.knative.dev/maxScale" = "2"
    }
    labels = local.resource_labels
  }

  traffic {
    percent         = 100
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}