resource "google_service_account" "iap_sa" {
  email   = "service-${data.google_project.project.number}@gcp-sa-iap.iam.gserviceaccount.com"
  display_name = "Identity-Aware Proxy's Default Service Account"
  create_ignore_already_exists = true
}

# Grant the Permission to IAP's default Service Account
resource "google_project_iam_member" "iap_user" {
  project = var.project_id
  role    = "roles/roles/iap.httpsResourceAccessor"
  member  = "serviceAccount:${google_service_account.iap_sa.email}"
}

resource "google_project_iam_member" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.iap_sa.email}"
}