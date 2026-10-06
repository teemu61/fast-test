/**
 * Google FAST Stage 1: Resource Management (1-resman)
 * Defines the core Landing Zone resource hierarchy (Folders).
 */

# -----------------------------------------------------------------------------
# Top-Level Folders under the GCP Organization
# -----------------------------------------------------------------------------

# Networking folder: houses Shared VPC host projects, VPNs, Interconnects, routers
resource "google_folder" "networking" {
  display_name = "${var.prefix}-networking"
  parent       = "organizations/${var.organization_id}"
}

# Security folder: houses centralized KMS keys, Certificate Authority Service (CAS), Secret Manager
resource "google_folder" "security" {
  display_name = "${var.prefix}-security"
  parent       = "organizations/${var.organization_id}"
}

# Common / Shared Services folder: houses shared tooling (CI/CD runners, monitoring, artifact registries)
resource "google_folder" "common" {
  display_name = "${var.prefix}-common"
  parent       = "organizations/${var.organization_id}"
}

# Workloads folder: root folder for all business application and team projects
resource "google_folder" "workloads" {
  display_name = "${var.prefix}-workloads"
  parent       = "organizations/${var.organization_id}"
}

# -----------------------------------------------------------------------------
# Environment Sub-Folders under Workloads
# -----------------------------------------------------------------------------

# Development environment folder
resource "google_folder" "workloads_dev" {
  display_name = "${var.prefix}-workloads-dev"
  parent       = google_folder.workloads.name
}

# Production environment folder
resource "google_folder" "workloads_prod" {
  display_name = "${var.prefix}-workloads-prod"
  parent       = google_folder.workloads.name
}
