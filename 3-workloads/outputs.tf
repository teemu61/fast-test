/**
 * Google FAST Stage 3: Workloads Outputs
 * Exports provisioned workload project ID, Cloud Run endpoint URL, and service identities.
 */

output "project_id" {
  description = "Project ID of the provisioned workload application project."
  value       = google_project.workload.project_id
}

output "project_number" {
  description = "Project number of the provisioned workload application project."
  value       = google_project.workload.number
}

output "service_name" {
  description = "Name of the deployed Cloud Run service."
  value       = google_cloud_run_v2_service.hello_world.name
}

output "service_url" {
  description = "Public HTTPS endpoint URL of the Cloud Run Hello World service."
  value       = google_cloud_run_v2_service.hello_world.uri
}

output "service_location" {
  description = "Google Cloud region where the Cloud Run service is deployed."
  value       = google_cloud_run_v2_service.hello_world.location
}

output "service_account_email" {
  description = "Email of the dedicated Cloud Run runtime service account."
  value       = google_service_account.cloud_run_sa.email
}

output "load_balancer_ip" {
  description = "Public static IPv4 address of the external HTTP(S) load balancer."
  value       = google_compute_global_address.default.address
}

output "load_balancer_url" {
  description = "Entrypoint URL via the external load balancer protected by Cloud Armor."
  value       = var.domain != null ? "https://${var.domain}" : "http://${google_compute_global_address.default.address}"
}

output "cloud_armor_policy_name" {
  description = "Name of the Google Cloud Armor security policy."
  value       = google_compute_security_policy.cloud_armor.name
}

output "cloud_armor_policy_id" {
  description = "Resource ID of the Google Cloud Armor security policy."
  value       = google_compute_security_policy.cloud_armor.id
}

output "serverless_neg_name" {
  description = "Name of the Serverless Network Endpoint Group connecting Cloud Run."
  value       = google_compute_region_network_endpoint_group.serverless_neg.name
}

# -----------------------------------------------------------------------------
# Kubernetes (GKE) Workload Outputs
# -----------------------------------------------------------------------------

output "gke_cluster_name" {
  description = "Name of the provisioned minimalist GKE cluster."
  value       = var.enable_gke ? google_container_cluster.primary[0].name : null
}

output "gke_cluster_location" {
  description = "GCP zone where the minimalist GKE cluster is deployed."
  value       = var.enable_gke ? google_container_cluster.primary[0].location : null
}

output "gke_cluster_endpoint" {
  description = "Kubernetes API server IP endpoint."
  value       = var.enable_gke ? google_container_cluster.primary[0].endpoint : null
}

output "gke_node_service_account" {
  description = "Email of the dedicated GKE worker node service account."
  value       = var.enable_gke ? google_service_account.gke_node_sa[0].email : null
}

output "gke_get_credentials_command" {
  description = "Convenience gcloud command to authenticate kubectl to the GKE cluster."
  value       = var.enable_gke ? "gcloud container clusters get-credentials ${google_container_cluster.primary[0].name} --zone ${google_container_cluster.primary[0].location} --project ${google_project.workload.project_id}" : null
}

output "gke_ingress_ip" {
  description = "Reserved static external IPv4 address for the GKE Ingress load balancer."
  value       = var.enable_gke ? google_compute_global_address.gke_ingress_ip[0].address : null
}

output "gke_ingress_url" {
  description = "Public URL to access the Hello World application on GKE via the External Load Balancer and Ingress."
  value       = var.enable_gke ? "http://${google_compute_global_address.gke_ingress_ip[0].address}" : null
}


