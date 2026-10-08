/**
 * Google FAST Stage 2: Networking Host Project
 * Provisions the dedicated Google Cloud project housing the Shared VPC,
 * enables core networking APIs, and designates it as a Shared VPC host.
 */

resource "random_string" "project_suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  project_id = var.project_id != null ? var.project_id : substr("${var.prefix}-${var.environment}-net-host-${random_string.project_suffix.result}", 0, 30)
  # Normalize folder ID to ensure 'folders/' prefix is handled cleanly
  folder_id = startswith(var.folder_id, "folders/") ? var.folder_id : "folders/${var.folder_id}"
}

# -----------------------------------------------------------------------------
# Host Project Definition
# -----------------------------------------------------------------------------

resource "google_project" "host_project" {
  name                = "${var.prefix}-${var.environment}-net-host"
  project_id          = local.project_id
  folder_id           = local.folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false

  labels = {
    environment = var.environment
    stage       = "stage2-networking"
    managed_by  = "terraform-fast"
  }
}

# -----------------------------------------------------------------------------
# Required Google Cloud APIs
# -----------------------------------------------------------------------------

resource "google_project_service" "services" {
  for_each           = toset(var.project_services)
  project            = google_project.host_project.project_id
  service            = each.value
  disable_on_destroy = false
}

# -----------------------------------------------------------------------------
# Shared VPC Host Designation
# -----------------------------------------------------------------------------

resource "google_compute_shared_vpc_host_project" "host" {
  project = google_project.host_project.project_id

  depends_on = [
    google_project_service.services["compute.googleapis.com"]
  ]
}
