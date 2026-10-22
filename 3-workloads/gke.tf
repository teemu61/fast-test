/**
 * Google FAST Stage 3: GKE Autopilot Cluster
 *
 * Implements a production-ready, security-hardened GKE Autopilot cluster
 * adhering to Google Cloud Foundation Fabric (FAST) standards.
 * Connects to Stage 2 Shared VPC with designated secondary IP ranges for Pods and Services.
 */

# -----------------------------------------------------------------------------
# Dedicated Node Service Account (Least Privilege)
# -----------------------------------------------------------------------------

resource "google_service_account" "gke_node_sa" {
  project      = google_project.workload.project_id
  account_id   = local.gke_node_sa_id
  display_name = "GKE Autopilot Node Service Account (${local.gke_cluster_name})"

  depends_on = [google_project_service.services]
}

# Assign minimal required roles for GKE worker nodes
resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader"
  ])

  project = google_project.workload.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

# -----------------------------------------------------------------------------
# GKE Autopilot Cluster
# -----------------------------------------------------------------------------

resource "google_container_cluster" "autopilot" {
  name     = local.gke_cluster_name
  project  = google_project.workload.project_id
  location = local.region

  # Enable GKE Autopilot mode
  enable_autopilot = true

  # Attach to Stage 2 Shared VPC and Regional Subnetwork
  network    = local.shared_vpc_network
  subnetwork = local.shared_vpc_subnetwork

  # VPC-Native Networking (Secondary IP ranges from Stage 2 Subnet)
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  # Cluster Autoscaling & Dedicated Node Service Account
  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.gke_node_sa.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }

  # Private Cluster Configuration (Nodes have private IPs, control plane accessible via public or authorized endpoints)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Release Channel for automatic upgrades and security patches
  release_channel {
    channel = "REGULAR"
  }

  # Production deletion protection flag
  deletion_protection = false

  # Resource labels
  resource_labels = {
    environment = local.environment
    managed_by  = "terraform-fast"
    stage       = "stage3-workloads"
    cluster     = local.gke_cluster_name
  }

  depends_on = [
    google_project_service.services,
    google_project_iam_member.gke_node_roles
  ]
}

# -----------------------------------------------------------------------------
# Static Global IPv4 Address for GKE Ingress Load Balancer
# -----------------------------------------------------------------------------

resource "google_compute_global_address" "gke_ingress_ip" {
  name        = local.gke_ingress_ip_name
  project     = google_project.workload.project_id
  description = "Global static IPv4 address for GKE Ingress HTTP(S) Load Balancer"

  depends_on = [google_project_service.services]
}
