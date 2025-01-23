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