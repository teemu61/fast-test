/**
 * Google FAST Stage 3: External HTTP(S) Load Balancer & Serverless NEG
 * Provisions a Global External Application Load Balancer with a Serverless NEG
 * connecting Cloud Run and protected by Google Cloud Armor.
 */

# -----------------------------------------------------------------------------
# Serverless Network Endpoint Group (NEG)
# -----------------------------------------------------------------------------

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = local.serverless_neg_name
  project               = google_project.workload.project_id
  region                = local.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.hello_world.name
  }

  depends_on = [
    google_project_service.services,
    google_cloud_run_v2_service.hello_world
  ]
}

# -----------------------------------------------------------------------------
# Global Backend Service (with Cloud Armor attached)
# -----------------------------------------------------------------------------

resource "google_compute_backend_service" "default" {
  name                  = local.backend_name
  project               = google_project.workload.project_id
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.cloud_armor.id

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  depends_on = [
    google_project_service.services,
    google_compute_security_policy.cloud_armor
  ]
}

# -----------------------------------------------------------------------------
# URL Map
# -----------------------------------------------------------------------------

resource "google_compute_url_map" "default" {
  name            = local.url_map_name
  project         = google_project.workload.project_id
  default_service = google_compute_backend_service.default.id

  depends_on = [google_project_service.services]
}

# -----------------------------------------------------------------------------
# Static Global IP Address
# -----------------------------------------------------------------------------

resource "google_compute_global_address" "default" {
  name        = local.lb_ip_name
  project     = google_project.workload.project_id
  description = "Global static IP address for Cloud Run external load balancer"

  depends_on = [google_project_service.services]
}

# -----------------------------------------------------------------------------
# HTTP Frontend (Port 80)
# -----------------------------------------------------------------------------

resource "google_compute_target_http_proxy" "default" {
  name    = local.http_proxy_name
  project = google_project.workload.project_id
  url_map = google_compute_url_map.default.id

  depends_on = [google_project_service.services]
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = local.http_rule_name
  project               = google_project.workload.project_id
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  depends_on = [google_project_service.services]
}

# -----------------------------------------------------------------------------
# Optional HTTPS Frontend (Port 443 with Managed SSL Certificate)
# Activated when var.domain is specified (e.g. 'hello.example.com')
# -----------------------------------------------------------------------------

resource "google_compute_managed_ssl_certificate" "default" {
  count   = var.domain != null ? 1 : 0
  name    = local.ssl_cert_name
  project = google_project.workload.project_id

  managed {
    domains = [var.domain]
  }

  depends_on = [google_project_service.services]
}

resource "google_compute_target_https_proxy" "default" {
  count   = var.domain != null ? 1 : 0
  name    = local.https_proxy_name
  project = google_project.workload.project_id
  url_map = google_compute_url_map.default.id

  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]

  depends_on = [google_project_service.services]
}

resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.domain != null ? 1 : 0
  name                  = local.https_rule_name
  project               = google_project.workload.project_id
  target                = google_compute_target_https_proxy.default[0].id
  port_range            = "443"
  ip_address            = google_compute_global_address.default.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  depends_on = [google_project_service.services]
}
