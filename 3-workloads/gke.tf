/**
 * Google FAST Stage 3: Minimalist GKE Cluster & Static Ingress IP
 * Deploys a cost-effective, single-zone Kubernetes cluster with a dedicated node
 * service account, HTTP load balancing enabled, and a static IP reserved for Ingress.
 */

# -----------------------------------------------------------------------------
# Dedicated Node Service Account & IAM Roles
# -----------------------------------------------------------------------------

resource "google_service_account" "gke_node_sa" {
  count        = var.enable_gke ? 1 : 0
  project      = google_project.workload.project_id
  account_id   = local.gke_node_sa_id
  display_name = "GKE Node Service Account (${local.gke_cluster_name})"

  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = var.enable_gke ? toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader"
  ]) : []

  project = google_project.workload.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_node_sa[0].email}"
}

# -----------------------------------------------------------------------------
# GKE Cluster (Control Plane)
# -----------------------------------------------------------------------------

resource "google_container_cluster" "primary" {
  count                    = var.enable_gke ? 1 : 0
  name                     = local.gke_cluster_name
  project                  = google_project.workload.project_id
  location                 = local.gke_zone
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  network    = var.gke_network != null ? var.gke_network : google_compute_network.gke_vpc[0].id
  subnetwork = var.gke_subnetwork != null ? var.gke_subnetwork : google_compute_subnetwork.gke_subnet[0].id

  # VPC-native networking using secondary IP ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Enable GKE Ingress controller (HTTP Load Balancing) and Network Policy
  addons_config {
    http_load_balancing {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  workload_identity_config {
    workload_pool = "${google_project.workload.project_id}.svc.id.goog"
  }

  depends_on = [
    google_project_service.services,
    google_compute_subnetwork.gke_subnet
  ]
}

# -----------------------------------------------------------------------------
# GKE Minimalist Node Pool
# -----------------------------------------------------------------------------

resource "google_container_node_pool" "primary_nodes" {
  count      = var.enable_gke ? 1 : 0
  name       = local.gke_nodepool_name
  project    = google_project.workload.project_id
  location   = local.gke_zone
  cluster    = google_container_cluster.primary[0].name
  node_count = var.gke_node_count

  node_config {
    machine_type    = var.gke_machine_type
    disk_size_gb    = var.gke_disk_size_gb
    disk_type       = "pd-standard"
    service_account = google_service_account.gke_node_sa[0].email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    tags = ["gke-${local.gke_cluster_name}"]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      environment = local.environment
      managed_by  = "terraform-fast"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  depends_on = [
    google_project_iam_member.gke_node_roles
  ]
}

# -----------------------------------------------------------------------------
# Static Global IP for GKE Ingress Load Balancer
# -----------------------------------------------------------------------------

resource "google_compute_global_address" "gke_ingress_ip" {
  count       = var.enable_gke ? 1 : 0
  name        = local.gke_ingress_ip_name
  project     = google_project.workload.project_id
  description = "Global static IP address for GKE Hello World Ingress load balancer"

  depends_on = [google_project_service.services]
}
