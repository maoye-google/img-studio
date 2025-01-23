resource "google_service_account" "app_sa" {
  account_id   = "${local.app_name}-imgstudio-sa"
  display_name = "Img Studio Application Service Account"
  create_ignore_already_exists = true
}

# Grant the Permission to ImgStudio App Service Account
resource "google_project_iam_member" "datastore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = google_service_account.app_sa.member
}

resource "google_project_iam_member" "logging_user" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.app_sa.member
}

resource "google_project_iam_member" "secret_user" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = google_service_account.app_sa.member
}

resource "google_project_iam_member" "sa_token_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = google_service_account.app_sa.member
}

resource "google_project_iam_member" "gcs_user" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = google_service_account.app_sa.member
}

resource "google_project_iam_member" "gcs_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = google_service_account.app_sa.member
}

resource "google_project_iam_member" "vertex_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = google_service_account.app_sa.member
}