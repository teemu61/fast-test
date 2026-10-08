/**
 * Google FAST Stage 0: Automation Project
 * Creates the seed Google Cloud project directly under the Organization,
 * enabling core management APIs and housing stage automation resources and state.
 */

resource "random_string" "project_suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  project_id = var.project_id != null ? var.project_id : substr("${var.prefix}-prod-iac-0-${random_string.project_suffix.result}", 0, 30)
}

# -----------------------------------------------------------------------------
# Automation Seed Project
# -----------------------------------------------------------------------------

resource "google_project" "automation" {
  name            = "${var.prefix}-prod-iac-0"
  project_id      = local.project_id
  org_id          = var.organization_id
  billing_account = var.billing_account_id

  labels = {
    environment = "prod"
    stage       = "stage0-bootstrap"
    managed_by  = "terraform-fast"
  }
}

# -----------------------------------------------------------------------------
# Core Management APIs
# -----------------------------------------------------------------------------

resource "google_project_service" "services" {
  for_each           = toset(var.project_services)
  project            = google_project.automation.project_id
  service            = each.value
  disable_on_destroy = false
}
