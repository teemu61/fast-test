/**
 * Google FAST Stage 2: Certificate Authority Service (CAS)
 * Provisions an internal Private CA Pool for issuing workload certificates (mTLS, internal HTTPS).
 */

resource "google_privateca_ca_pool" "ca_pool" {
  count = var.enable_ca_service ? 1 : 0

  name     = "${var.prefix}-${var.environment}-ca-pool"
  location = var.kms_regions[0]
  project  = google_project.security_project.project_id
  tier     = var.ca_pool_tier

  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }

  labels = {
    environment = var.environment
    stage       = "stage2-security"
    managed_by  = "terraform-fast"
  }

  depends_on = [
    google_project_service.services["privateca.googleapis.com"]
  ]
}
