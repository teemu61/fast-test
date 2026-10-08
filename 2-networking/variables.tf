/**
 * Google FAST Stage 2: Networking (2-networking)
 * Input variables consumable from Stage 1 contracts or standalone tfvars.
 */

# -----------------------------------------------------------------------------
# Stage 1 Contract Inputs (folder_id, billing_account_id, automation_sa)
# These match the keys output by Stage 1's stage2_networking_inputs.
# -----------------------------------------------------------------------------

variable "folder_id" {
  description = "Resource ID of the Networking folder created in Stage 1 (e.g. 'folders/1234567890')."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID to associate with the networking host project."
  type        = string
}

variable "automation_sa" {
  description = "Service account provisioned for Stage 2 Networking deployment."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# General FAST Project Configuration
# -----------------------------------------------------------------------------

variable "prefix" {
  description = "Prefix prepended to resource names to enforce FAST naming standards."
  type        = string
  default     = "fast"
}

variable "environment" {
  description = "Environment identifier (e.g. 'prod', 'dev', 'staging')."
  type        = string
  default     = "prod"
}

variable "project_id" {
  description = "Custom Project ID for the Shared VPC host project. If null, a deterministic FAST ID with random suffix is generated."
  type        = string
  default     = null
}

variable "project_services" {
  description = "List of GCP APIs to enable on the Shared VPC host project."
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

# -----------------------------------------------------------------------------
# VPC and Subnet Configuration
# -----------------------------------------------------------------------------

variable "vpc_name" {
  description = "Name of the Shared VPC network. If null, defaults to '<prefix>-<environment>-shared-vpc'."
  type        = string
  default     = null
}

variable "routing_mode" {
  description = "Network routing mode (GLOBAL or REGIONAL)."
  type        = string
  default     = "GLOBAL"
}

variable "delete_default_routes_on_create" {
  description = "Whether to delete default internet gateway routes on VPC creation."
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Subnets to configure in the Shared VPC, with support for secondary IP ranges (GKE) and flow logs."
  type = list(object({
    name          = string
    region        = string
    ip_cidr_range = string
    description   = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
    flow_logs_enabled     = optional(bool, false)
    flow_logs_interval    = optional(string, "INTERVAL_5_SEC")
    flow_logs_sample_rate = optional(number, 0.5)
  }))
  default = [
    {
      name          = "prod-europe-west1-core"
      region        = "europe-west1"
      ip_cidr_range = "10.10.0.0/24"
      description   = "Primary production subnet in europe-west1"
      secondary_ip_ranges = [
        {
          range_name    = "pods"
          ip_cidr_range = "10.100.0.0/16"
        },
        {
          range_name    = "services"
          ip_cidr_range = "10.101.0.0/20"
        }
      ]
      flow_logs_enabled = true
    },
    {
      name          = "prod-europe-west4-core"
      region        = "europe-west4"
      ip_cidr_range = "10.20.0.0/24"
      description   = "Secondary production subnet in europe-west4"
      secondary_ip_ranges = [
        {
          range_name    = "pods"
          ip_cidr_range = "10.200.0.0/16"
        },
        {
          range_name    = "services"
          ip_cidr_range = "10.201.0.0/20"
        }
      ]
      flow_logs_enabled = false
    }
  ]
}

# -----------------------------------------------------------------------------
# Cloud Router and Cloud NAT Configuration
# -----------------------------------------------------------------------------

variable "enable_cloud_nat" {
  description = "Whether to provision Cloud Router and Cloud NAT in each active subnet region for outbound internet access."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Firewall Rules Configuration
# -----------------------------------------------------------------------------

variable "enable_baseline_firewall" {
  description = "Whether to deploy foundational FAST firewall rules (internal RFC1918, Google health checks, IAP SSH)."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Private Cloud DNS Configuration
# -----------------------------------------------------------------------------

variable "enable_private_dns" {
  description = "Whether to provision a Private Cloud DNS zone associated with the Shared VPC."
  type        = bool
  default     = true
}

variable "dns_domain" {
  description = "Private DNS domain name (must end with trailing dot, e.g. 'gcp.internal.')."
  type        = string
  default     = "gcp.internal."
}
