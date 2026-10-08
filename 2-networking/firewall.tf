/**
 * Google FAST Stage 2: Baseline Firewall Rules
 * Provisions foundational security guardrails enforcing least privilege ingress:
 * 1. Internal RFC1918 cross-subnet traffic
 * 2. Google Cloud load balancer health checks
 * 3. Identity-Aware Proxy (IAP) bastionless SSH/RDP access
 */

# -----------------------------------------------------------------------------
# Allow Internal RFC1918 Ingress
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "allow_internal" {
  count = var.enable_baseline_firewall ? 1 : 0

  name        = "${var.prefix}-${var.environment}-fw-allow-internal"
  project     = google_project.host_project.project_id
  network     = google_compute_network.shared_vpc.name
  description = "Allow internal ingress traffic across private RFC1918 address space."
  priority    = 1000

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

# -----------------------------------------------------------------------------
# Allow Google Cloud Health Checks
# Required for Cloud Load Balancing (Regional & Global L4/L7 load balancers)
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "allow_health_checks" {
  count = var.enable_baseline_firewall ? 1 : 0

  name        = "${var.prefix}-${var.environment}-fw-allow-health-checks"
  project     = google_project.host_project.project_id
  network     = google_compute_network.shared_vpc.name
  description = "Allow Google Cloud Load Balancer health check probe IP ranges."
  priority    = 1000

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  allow {
    protocol = "tcp"
  }
}

# -----------------------------------------------------------------------------
# Allow Identity-Aware Proxy (IAP) Tunneling
# Permits secure SSH (22) and RDP (3389) without assigning public IP addresses
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "allow_iap" {
  count = var.enable_baseline_firewall ? 1 : 0

  name        = "${var.prefix}-${var.environment}-fw-allow-iap"
  project     = google_project.host_project.project_id
  network     = google_compute_network.shared_vpc.name
  description = "Allow Identity-Aware Proxy (IAP) ingress for secure VM administrative access."
  priority    = 1000

  source_ranges = [
    "35.235.240.0/20"
  ]

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}
