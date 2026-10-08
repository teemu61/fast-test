/**
 * Google FAST Stage 2: Subnetworks
 * Provisions subnets with Private Google Access enabled and support for
 * secondary IP ranges (GKE Pods/Services) and VPC Flow Logs.
 */

resource "google_compute_subnetwork" "subnets" {
  for_each = { for s in var.subnets : s.name => s }

  name                     = each.value.name
  project                  = google_project.host_project.project_id
  region                   = each.value.region
  network                  = google_compute_network.shared_vpc.id
  ip_cidr_range            = each.value.ip_cidr_range
  description              = coalesce(each.value.description, "Subnet ${each.value.name} in ${each.value.region}")
  private_ip_google_access = true

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = each.value.flow_logs_enabled ? [1] : []
    content {
      aggregation_interval = each.value.flow_logs_interval
      flow_sampling        = each.value.flow_logs_sample_rate
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}
