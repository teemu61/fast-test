/**
 * Google FAST Stage 2: Cloud Router and Cloud NAT
 * Provides egress internet connectivity for workloads hosted in private subnets
 * without attaching external public IPs directly to Compute Engine or GKE nodes.
 */

locals {
  # Automatically determine unique regions where subnets are deployed
  nat_regions = distinct([for s in var.subnets : s.region])
}

# -----------------------------------------------------------------------------
# Cloud Router (one per region)
# -----------------------------------------------------------------------------

resource "google_compute_router" "routers" {
  for_each = var.enable_cloud_nat ? toset(local.nat_regions) : toset([])

  name    = "${var.prefix}-${var.environment}-router-${each.value}"
  project = google_project.host_project.project_id
  region  = each.value
  network = google_compute_network.shared_vpc.id
}

# -----------------------------------------------------------------------------
# Cloud NAT Gateway (one per region)
# -----------------------------------------------------------------------------

resource "google_compute_router_nat" "nats" {
  for_each = var.enable_cloud_nat ? toset(local.nat_regions) : toset([])

  name                               = "${var.prefix}-${var.environment}-nat-${each.value}"
  project                            = google_project.host_project.project_id
  router                             = google_compute_router.routers[each.value].name
  region                             = each.value
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
