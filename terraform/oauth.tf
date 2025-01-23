resource "google_project_service" "project_iap_service" {
  project = var.project_id
  service = "iap.googleapis.com"
}

resource "google_iap_brand" "iap_oauth_app" {
  support_email     = "maoye@google.com" # Replace with your support email
  project           = var.project_id

  application_title = "(IAP protected) {ver.app_name}"

  deletion_policy = "DELETE"
}

# Create OAuth Client ID
resource "google_iap_client" "iap_oauth_client" {
  brand        = google_iap_brand.iap_oauth_app.name
  display_name = "IAP OAuth Client"
}

resource "google_iap_web_backend_service_iam_binding" "iap_binding" {
  project            = var.project_id
  web_backend_service = google_compute_backend_service.default.name
  role               = "roles/iap.httpsResourceAccessor"

  # members = [
  #  "user:test-user@example.com",
  #  "group:iap-access@example.com",
  # ]
}



