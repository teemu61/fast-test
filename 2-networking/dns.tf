/**
 * Google FAST Stage 2: Private Cloud DNS
 * Provisions an internal Private DNS zone bound to the Shared VPC for
 * service discovery and internal hostname resolution.
 */

resource "google_dns_managed_zone" "private_zone" {
  count = var.enable_private_dns ? 1 : 0

  name        = "${var.prefix}-${var.environment}-private-dns"
  dns_name    = var.dns_domain
  description = "Internal private DNS zone for ${var.environment} Shared VPC."
  visibility  = "private"
  project     = google_project.host_project.project_id

  private_visibility_config {
    networks {
      network_url = google_compute_network.shared_vpc.id
    }
  }

  depends_on = [
    google_project_service.services["dns.googleapis.com"]
  ]
}
