/**
 * Google FAST Stage 1: Resource Manager Hierarchical Tags
 * Defines organization-level Tag Keys and Tag Values, and binds them to folders.
 * Used for IAM conditional access, billing attribution, and security policy scoping.
 */

# -----------------------------------------------------------------------------
# Tag Key: Context (functional domain)
# -----------------------------------------------------------------------------
resource "google_tags_tag_key" "context" {
  count       = var.enable_tags ? 1 : 0
  parent      = "organizations/${var.organization_id}"
  short_name  = "${var.prefix}-context"
  description = "FAST functional context (networking, security, workloads, common)"
}

resource "google_tags_tag_value" "context_networking" {
  count       = var.enable_tags ? 1 : 0
  parent      = google_tags_tag_key.context[0].id
  short_name  = "networking"
  description = "Shared networking infrastructure"
}

resource "google_tags_tag_value" "context_security" {
  count       = var.enable_tags ? 1 : 0
  parent      = google_tags_tag_key.context[0].id
  short_name  = "security"
  description = "Centralized security services (KMS, CAS, Secret Manager)"
}

resource "google_tags_tag_value" "context_workloads" {
  count       = var.enable_tags ? 1 : 0
  parent      = google_tags_tag_key.context[0].id
  short_name  = "workloads"
  description = "Application and data workloads"
}

# -----------------------------------------------------------------------------
# Tag Key: Environment
# -----------------------------------------------------------------------------
resource "google_tags_tag_key" "environment" {
  count       = var.enable_tags ? 1 : 0
  parent      = "organizations/${var.organization_id}"
  short_name  = "${var.prefix}-environment"
  description = "Deployment lifecycle environment"
}

resource "google_tags_tag_value" "env_development" {
  count       = var.enable_tags ? 1 : 0
  parent      = google_tags_tag_key.environment[0].id
  short_name  = "development"
  description = "Development environment"
}

resource "google_tags_tag_value" "env_production" {
  count       = var.enable_tags ? 1 : 0
  parent      = google_tags_tag_key.environment[0].id
  short_name  = "production"
  description = "Production environment"
}

# -----------------------------------------------------------------------------
# Tag Bindings to Folders
# -----------------------------------------------------------------------------
resource "google_tags_tag_binding" "networking_context" {
  count     = var.enable_tags ? 1 : 0
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.networking.name}"
  tag_value = google_tags_tag_value.context_networking[0].id
}

resource "google_tags_tag_binding" "security_context" {
  count     = var.enable_tags ? 1 : 0
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.security.name}"
  tag_value = google_tags_tag_value.context_security[0].id
}

resource "google_tags_tag_binding" "workloads_context" {
  count     = var.enable_tags ? 1 : 0
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.workloads.name}"
  tag_value = google_tags_tag_value.context_workloads[0].id
}

resource "google_tags_tag_binding" "workloads_dev_env" {
  count     = var.enable_tags ? 1 : 0
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.workloads_dev.name}"
  tag_value = google_tags_tag_value.env_development[0].id
}

resource "google_tags_tag_binding" "workloads_prod_env" {
  count     = var.enable_tags ? 1 : 0
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.workloads_prod.name}"
  tag_value = google_tags_tag_value.env_production[0].id
}
