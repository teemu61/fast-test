/**
 * Google FAST Stage 2: Shared VPC Network
 * Provisions the custom-mode VPC network serving as the enterprise Shared VPC.
 */

locals {
  vpc_name = var.vpc_name != null ? var.vpc_name : "${var.prefix}-${var.environment}-shared-vpc"
}

resource "google_compute_network" "shared_vpc" {
  name                            = local.vpc_name
  project                         = google_project.host_project.project_id
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
  description                     = "Shared VPC network for ${var.environment} workloads managed by FAST Stage 2."

  depends_on = [
    google_project_service.services["compute.googleapis.com"]
  ]
}
