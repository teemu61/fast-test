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

  # In production FAST deployments, state is kept in the GCS bucket created in Stage 0:
  # backend "gcs" {
  #   bucket = "fast-prod-stage2-pf-terraform-state"
  #   prefix = "fast/stages/3-workloads"
  # }
}

provider "google" {
  # In FAST, Terraform impersonates the Stage 2/3 Project Factory automation service account
  # provisioned during Stage 0 (Bootstrap) and delegated in Stage 1:
  # impersonate_service_account = var.automation_sa
}

provider "google-beta" {
  # impersonate_service_account = var.automation_sa
}
