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
# GKE Autopilot & GitOps Workload Outputs
# -----------------------------------------------------------------------------

output "gke_cluster_name" {
  description = "Name of the provisioned GKE Autopilot cluster."
  value       = google_container_cluster.autopilot.name
}

output "gke_cluster_location" {
  description = "GCP region where the GKE Autopilot cluster is deployed."
  value       = google_container_cluster.autopilot.location
}

output "gke_cluster_endpoint" {
  description = "Kubernetes API server IP endpoint."
  value       = google_container_cluster.autopilot.endpoint
}

output "gke_node_service_account" {
  description = "Email of the dedicated GKE worker node service account."
  value       = google_service_account.gke_node_sa.email
}

output "gke_get_credentials_command" {
  description = "Convenience gcloud command to authenticate kubectl to the GKE cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.autopilot.name} --region ${google_container_cluster.autopilot.location} --project ${google_project.workload.project_id}"
}

output "gke_ingress_ip" {
  description = "Reserved static external IPv4 address for the GKE Ingress load balancer."
  value       = google_compute_global_address.gke_ingress_ip.address
}

output "gke_ingress_url" {
  description = "Public URL to access the Hello World application on GKE via the External Load Balancer and Ingress."
  value       = var.domain != null ? "https://${var.domain}" : "http://${google_compute_global_address.gke_ingress_ip.address}"
}

output "eso_service_account_email" {
  description = "Email of the GCP Service Account provisioned for External Secrets Operator."
  value       = google_service_account.eso_sa.email
}

output "secret_manager_db_password_id" {
  description = "Secret ID of the database password secret in GCP Secret Manager."
  value       = google_secret_manager_secret.db_password.secret_id
}

output "argocd_application_name" {
  description = "Name of the root ArgoCD GitOps Application."
  value       = local.argocd_app_name
}



