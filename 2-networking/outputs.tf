/**
 * Google FAST Stage 2: Networking Outputs
 * Exports host project details, Shared VPC attributes, subnets, and
 * the Stage 3 contract object consumable by downstream Workloads & Project Factory.
 */

output "host_project_id" {
  description = "Project ID of the Shared VPC host project."
  value       = google_project.host_project.project_id
}

output "host_project_number" {
  description = "Project number of the Shared VPC host project."
  value       = google_project.host_project.number
}

output "network_name" {
  description = "Name of the Shared VPC network."
  value       = google_compute_network.shared_vpc.name
}

output "network_id" {
  description = "URI identifier of the Shared VPC network."
  value       = google_compute_network.shared_vpc.id
}

output "network_self_link" {
  description = "Self-link of the Shared VPC network."
  value       = google_compute_network.shared_vpc.self_link
}

output "subnets" {
  description = "Map of created subnets and their configuration details."
  value = {
    for name, s in google_compute_subnetwork.subnets : name => {
      id            = s.id
      self_link     = s.self_link
      name          = s.name
      region        = s.region
      ip_cidr_range = s.ip_cidr_range
      secondary_ip_ranges = [
        for sec in s.secondary_ip_range : {
          range_name    = sec.range_name
          ip_cidr_range = sec.ip_cidr_range
        }
      ]
    }
  }
}

output "nat_routers" {
  description = "Cloud Routers provisioned for NAT per region."
  value = {
    for r, router in google_compute_router.routers : r => router.name
  }
}

output "dns_zone" {
  description = "Details of the private DNS managed zone if enabled."
  value = var.enable_private_dns ? {
    name        = google_dns_managed_zone.private_zone[0].name
    dns_name    = google_dns_managed_zone.private_zone[0].dns_name
    name_server = google_dns_managed_zone.private_zone[0].name_servers
  } : null
}

# -----------------------------------------------------------------------------
# FAST Stage Contracts: Outputs consumable by Stage 3 (Workloads / Project Factory)
# -----------------------------------------------------------------------------

output "stage3_workload_inputs" {
  description = "Stage 3 contract containing host project, network, and subnet references needed to attach service projects."
  value = {
    host_project_id   = google_project.host_project.project_id
    network_self_link = google_compute_network.shared_vpc.self_link
    subnet_self_links = {
      for name, s in google_compute_subnetwork.subnets : name => s.self_link
    }
    subnet_names = [
      for s in google_compute_subnetwork.subnets : s.name
    ]
  }
}
