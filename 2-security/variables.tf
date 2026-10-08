/**
 * Google FAST Stage 2: Security (2-security)
 * Input variables consumable from Stage 1 contracts or standalone tfvars.
 */

# -----------------------------------------------------------------------------
# Stage 1 Contract Inputs (folder_id, billing_account_id, automation_sa)
# These match the keys output by Stage 1's stage2_security_inputs.
# -----------------------------------------------------------------------------

variable "folder_id" {
  description = "Resource ID of the Security folder created in Stage 1 (e.g. 'folders/1234567890')."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID to associate with the security project."
  type        = string
}

variable "automation_sa" {
  description = "Service account provisioned for Stage 2 Security deployment."
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
  description = "Custom Project ID for the security project. If null, a deterministic FAST ID with random suffix is generated."
  type        = string
  default     = null
}

variable "project_services" {
  description = "List of GCP APIs to enable on the security core project."
  type        = list(string)
  default = [
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "privateca.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

# -----------------------------------------------------------------------------
# Cloud KMS Configuration
# -----------------------------------------------------------------------------

variable "kms_regions" {
  description = "Regions where Cloud KMS Key Rings will be provisioned."
  type        = list(string)
  default     = ["europe-west1", "europe-west4"]
}

variable "kms_key_purposes" {
  description = "Purposes for which Customer-Managed Encryption Keys (CMEK) are created in each region."
  type        = list(string)
  default     = ["compute", "storage", "bigquery", "gke"]
}

variable "key_rotation_period" {
  description = "Automatic rotation period for symmetric encryption keys (e.g. '7776000s' = 90 days)."
  type        = string
  default     = "7776000s"
}

# -----------------------------------------------------------------------------
# Secret Manager Configuration
# -----------------------------------------------------------------------------

variable "enable_secret_manager" {
  description = "Whether to provision baseline Secret Manager resources."
  type        = bool
  default     = true
}

variable "secrets" {
  description = "Baseline secrets to define in Secret Manager (without plain text values)."
  type = map(object({
    description = optional(string)
    labels      = optional(map(string), {})
  }))
  default = {
    "bootstrap-credentials" = {
      description = "Credentials for landing zone bootstrap integration"
      labels      = { tier = "admin" }
    }
  }
}

# -----------------------------------------------------------------------------
# Certificate Authority Service (CAS) Configuration
# -----------------------------------------------------------------------------

variable "enable_ca_service" {
  description = "Whether to provision a Private CA Pool for internal certificate issuance."
  type        = bool
  default     = true
}

variable "ca_pool_tier" {
  description = "Tier of the Private CA Pool ('DEVOPS' for high-volume internal certs, or 'ENTERPRISE')."
  type        = string
  default     = "DEVOPS"
}
