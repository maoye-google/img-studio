resource "google_project_service" "project_iap_service" {
  project = var.project_id
  service = "iap.googleapis.com"
}

data "google_iap_brand" "existing_iap_oauth_app" {
  provider = google-beta
  project = var.project_id
}

resource "google_iap_brand" "iap_oauth_app" {
  provider = google-beta
  support_email     = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  project           = var.project_id
  application_title = var.app_name

   # Create only if the brand doesn't exist
  count = data.google_iap_brand.existing_iap_oauth_app.id == null ? 1 : 0
}

# Create OAuth Client ID
resource "google_iap_client" "iap_oauth_client" {
  brand        = var.app_name
  display_name = "IAP OAuth Client"
}

resource "google_project_service_identity" "iap_sa" {
  provider = google-beta
  project = var.project_id
  service = "iap.googleapis.com"
}

# Grant the Permission to IAP's default Service Account
# resource "google_project_iam_member" "iap_user" {
#  project = var.project_id
#  role    = "roles/roles/iap.httpsResourceAccessor"
#  member  = google_project_service_identity.iap_sa.member
# }

# resource "google_project_iam_member" "run_invoker" {
#  project = var.project_id
#  role    = "roles/run.invoker"
#  member  = google_project_service_identity.iap_sa.member
# }

resource "google_iap_web_backend_service_iam_binding" "iap_binding" {
  project            = var.project_id
  web_backend_service = google_compute_backend_service.default.name
  role               = "roles/iap.httpsResourceAccessor"

  members = [
    "user:admin@maoye.altostrat.com", # add your preferred test user here
    google_project_service_identity.iap_sa.member
  ]
}



