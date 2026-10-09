/**
 * Google FAST Stage 3: Workload Application Project
 * Creates the dedicated application project under the Workloads folder,
 * links billing, and enables Cloud Run and operational monitoring APIs.
 */

resource "random_string" "project_suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  project_id = var.project_id != null ? var.project_id : substr("${var.prefix}-${var.environment}-app-${random_string.project_suffix.result}", 0, 30)
}

# -----------------------------------------------------------------------------
# Workload Application Project
# -----------------------------------------------------------------------------

resource "google_project" "workload" {
  name            = "${var.prefix}-${var.environment}-app"
  project_id      = local.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id

  labels = {
    environment = var.environment
    stage       = "stage3-workloads"
    application = "hello-world"
    managed_by  = "terraform-fast"
  }
}

# -----------------------------------------------------------------------------
# Enable Project APIs
# -----------------------------------------------------------------------------

resource "google_project_service" "services" {
  for_each           = toset(var.project_services)
  project            = google_project.workload.project_id
  service            = each.value
  disable_on_destroy = false
}
