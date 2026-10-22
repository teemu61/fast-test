/**
 * Google FAST Stage 3: Dedicated Workload VPC & Subnets for GKE
 * Provisions a dedicated VPC network, subnetwork with secondary ranges for
 * Kubernetes Pods and Services, Cloud Router, Cloud NAT, and health check firewall rules
 * when an external Shared VPC is not provided.
 */

# -----------------------------------------------------------------------------
# Dedicated Workload VPC
# -----------------------------------------------------------------------------

resource "google_compute_network" "gke_vpc" {
  count                   = var.enable_gke && var.gke_network == null ? 1 : 0
  name                    = local.gke_network_name
  project                 = google_project.workload.project_id
  auto_create_subnetworks = false
  description             = "Dedicated VPC for FAST Stage 3 GKE workload"

  depends_on = [google_project_service.services]
}

# -----------------------------------------------------------------------------
# GKE Subnetwork with Secondary Ranges (Pods & Services)
# -----------------------------------------------------------------------------

resource "google_compute_subnetwork" "gke_subnet" {
  count                    = var.enable_gke && var.gke_subnetwork == null ? 1 : 0
  name                     = local.gke_subnet_name
  project                  = google_project.workload.project_id
  region                   = local.region
  network                  = var.gke_network != null ? var.gke_network : google_compute_network.gke_vpc[0].id
  ip_cidr_range            = var.gke_nodes_cidr
  private_ip_google_access = true
  description              = "Subnetwork for GKE nodes, pods, and services"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.gke_pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.gke_services_cidr
  }

  depends_on = [google_project_service.services]
}

# -----------------------------------------------------------------------------
# Cloud Router & Cloud NAT (Egress for private nodes)
# -----------------------------------------------------------------------------

resource "google_compute_router" "gke_router" {
  count   = var.enable_gke && var.gke_network == null ? 1 : 0
  name    = "${var.prefix}-${local.environment}-gke-router"
  project = google_project.workload.project_id
  region  = local.region
  network = google_compute_network.gke_vpc[0].id

  depends_on = [google_project_service.services]
}

resource "google_compute_router_nat" "gke_nat" {
  count                              = var.enable_gke && var.gke_network == null ? 1 : 0
  name                               = "${var.prefix}-${local.environment}-gke-nat"
  project                            = google_project.workload.project_id
  router                             = google_compute_router.gke_router[0].name
  region                             = local.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [google_project_service.services]
}

# -----------------------------------------------------------------------------
# Firewall Rules: Google Cloud Load Balancer (GLBC) Health Checks
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "gke_health_checks" {
  count       = var.enable_gke && var.gke_network == null ? 1 : 0
  name        = "${var.prefix}-${local.environment}-allow-glbc-health-checks"
  project     = google_project.workload.project_id
  network     = google_compute_network.gke_vpc[0].id
  description = "Allows Google Cloud Load Balancer and health checks to reach GKE nodes and pods"

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  allow {
    protocol = "tcp"
  }

  target_tags = ["gke-${local.gke_cluster_name}"]

  depends_on = [google_project_service.services]
}
