# Default GCS Bucket to store generated files
resource "google_storage_bucket" "output_bucket" {
 name          = "${locals.app_name}-imgstudio-output"
 location      = var.region
 uniform_bucket_level_access = true
 force_destroy = true
}

# Default GCS Bucket for team to share images
resource "google_storage_bucket" "team_bucket" {
 name          = "${locals.app_name}-imgstudio-library"
 location      = var.region
 uniform_bucket_level_access = true
 force_destroy = true
}

# Default GCS Bucket to store JSON configuration files
resource "google_storage_bucket" "config_bucket" {
 name          = "${locals.app_name}-imgstudio-export-config"
 location      = var.region
 uniform_bucket_level_access = true
 force_destroy = true
}

## -------------------------------------------

# Upload Default JSON configuration files to Cloud
resource "google_storage_bucket_object" "uploaded_config" {
  name   = "export-fields-options.json"
  bucket = google_storage_bucket.config_bucket.name
  source = "../config/export-fields-options.json"
  content_type = "application/json"
}
