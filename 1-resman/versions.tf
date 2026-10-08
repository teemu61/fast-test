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
  }

  # In production FAST deployments, state is kept in the GCS bucket created in Stage 0:
  # backend "gcs" {
  #   bucket = "fast-prod-stage1-terraform-state"
  #   prefix = "fast/stages/1-resman"
  # }
}

provider "google" {
  # In FAST, Terraform impersonates the Stage 1 automation service account
  # provisioned during Stage 0 (Bootstrap):
  # impersonate_service_account = var.stage0_automation_service_accounts.resman
}

provider "google-beta" {
  # impersonate_service_account = var.stage0_automation_service_accounts.resman
}
