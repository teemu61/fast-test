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

