terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0, < 7.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0.0, < 7.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }

  # Stage 0 is initially executed with local state by a human super-admin (Org Admin + Billing Admin).
  # Once the bootstrap state bucket is created, state is migrated to GCS:
  # backend "gcs" {
  #   bucket = "fast-prod-stage0-terraform-state"
  #   prefix = "fast/stages/0-bootstrap"
  # }
}

provider "google" {
  # Stage 0 executes directly under the identity of the superadmin or seed CI pipeline.
}

provider "google-beta" {
}
