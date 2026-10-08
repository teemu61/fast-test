variable "organization_id" {
  description = "GCP Organization ID (numeric format, e.g., '123456789012')."
  type        = string
}

variable "prefix" {
  description = "Prefix prepended to resource names to enforce FAST naming standards."
  type        = string
  default     = "fast"
}

variable "billing_account_id" {
  description = "Billing account ID used across the landing zone (e.g., '012345-6789AB-CDEF01')."
  type        = string
  default     = null
}

variable "admin_principals" {
  description = "Administrative user groups or principals mapped to functional roles."
  type = object({
    org_admins      = optional(string, "group:gcp-organization-admins@example.com")
    network_admins  = optional(string, "group:gcp-network-admins@example.com")
    security_admins = optional(string, "group:gcp-security-admins@example.com")
    devops_admins   = optional(string, "group:gcp-devops-admins@example.com")
  })
  default = {}
}

variable "stage0_automation_service_accounts" {
  description = "Automation service accounts provisioned by FAST Stage 0 (Bootstrap) for delegation."
  type = object({
    resman          = string # Stage 1 SA (Self / Resource Management)
    networking      = string # Stage 2 SA (Networking)
    security        = string # Stage 2 SA (Security)
    project_factory = string # Stage 2/3 SA (Workloads & Project Factory)
  })
}

variable "org_policies_enabled" {
  description = "Whether to enforce foundational organization policies at the organization level."
  type        = bool
  default     = true
}

variable "enable_tags" {
  description = "Whether to create and bind hierarchical resource manager tags."
  type        = bool
  default     = true
}
