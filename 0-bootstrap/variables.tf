/**
 * Google FAST Stage 0: Bootstrap (0-bootstrap)
 * Input variables defining organization, billing, and administration identities.
 */

# -----------------------------------------------------------------------------
# Organization and Billing
# -----------------------------------------------------------------------------

variable "organization_id" {
  description = "GCP Organization ID (numeric format, e.g., '123456789012')."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID used across the landing zone (e.g., '012345-6789AB-CDEF01')."
  type        = string
}

variable "prefix" {
  description = "Prefix prepended to resource names to enforce FAST naming standards."
  type        = string
  default     = "fast"
}

# -----------------------------------------------------------------------------
# Automation Host Project Configuration
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Custom Project ID for the seed automation project. If null, a deterministic FAST ID with random suffix is generated."
  type        = string
  default     = null
}

variable "project_services" {
  description = "Google APIs to enable on the automation seed project."
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "cloudbilling.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

# -----------------------------------------------------------------------------
# Terraform State Storage Configuration
# -----------------------------------------------------------------------------

variable "storage_location" {
  description = "Location / Multi-region for the Terraform state GCS buckets (e.g. 'EU', 'US', 'europe-west1')."
  type        = string
  default     = "EU"
}

# -----------------------------------------------------------------------------
# Administrative Identities
# -----------------------------------------------------------------------------

variable "admin_principals" {
  description = "Administrative user groups or principals granted break-glass impersonation and stage oversight."
  type = object({
    org_admins      = optional(string, "group:gcp-organization-admins@example.com")
    network_admins  = optional(string, "group:gcp-network-admins@example.com")
    security_admins = optional(string, "group:gcp-security-admins@example.com")
    devops_admins   = optional(string, "group:gcp-devops-admins@example.com")
  })
  default = {}
}

# -----------------------------------------------------------------------------
# Feature Toggles
# -----------------------------------------------------------------------------

variable "grant_org_roles" {
  description = "Whether to bind organization-level IAM roles to stage automation service accounts."
  type        = bool
  default     = true
}

variable "grant_billing_roles" {
  description = "Whether to grant billing account user permissions to stage automation service accounts."
  type        = bool
  default     = true
}
