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
