/**
 * Google FAST Stage 2: Security Project
 * Provisions the centralized Google Cloud project housing KMS Key Rings,
 * Secret Manager, and Certificate Authority Service (CAS).
 */

resource "random_string" "project_suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  project_id = var.project_id != null ? var.project_id : substr("${var.prefix}-${var.environment}-sec-core-${random_string.project_suffix.result}", 0, 30)
  folder_id  = startswith(var.folder_id, "folders/") ? var.folder_id : "folders/${var.folder_id}"
}

# -----------------------------------------------------------------------------
# Security Project Definition
# -----------------------------------------------------------------------------

resource "google_project" "security_project" {
  name                = "${var.prefix}-${var.environment}-sec-core"
  project_id          = local.project_id
  folder_id           = local.folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false

  labels = {
    environment = var.environment
    stage       = "stage2-security"
    managed_by  = "terraform-fast"
  }
}

# -----------------------------------------------------------------------------
# Required Security APIs
# -----------------------------------------------------------------------------

resource "google_project_service" "services" {
  for_each           = toset(var.project_services)
  project            = google_project.security_project.project_id
  service            = each.value
  disable_on_destroy = false
}
