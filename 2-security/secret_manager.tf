/**
 * Google FAST Stage 2: Secret Manager
 * Provisions centralized secret resources with automatic replication and labels.
 */

resource "google_secret_manager_secret" "secrets" {
  for_each = var.enable_secret_manager ? var.secrets : {}

  secret_id = each.key
  project   = google_project.security_project.project_id

  replication {
    auto {}
  }

  labels = merge(each.value.labels, {
    environment = var.environment
    stage       = "stage2-security"
    managed_by  = "terraform-fast"
  })

  depends_on = [
    google_project_service.services["secretmanager.googleapis.com"]
  ]
}
