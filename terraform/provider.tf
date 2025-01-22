terraform {
  backend "gcs" {
  }

  required_providers {
    google = {
      version = "~> 6.16.0"
    }
  }

  provider_meta "google" {
    module_name = "img-studio-v1.0"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
