/**
 * Google FAST Stage 1: IAM Delegation
 * Grants scoped permissions to stage automation service accounts & admin groups.
 * This implements the FAST principle of least privilege: separating networking,
 * security, and application workload pipelines.
 */

# -----------------------------------------------------------------------------
# Networking Branch IAM Delegation (Stage 2 Networking Automation)
# -----------------------------------------------------------------------------

# Shared VPC Administration on the Networking folder
resource "google_folder_iam_member" "network_sa_xpn_admin" {
  folder = google_folder.networking.name
  role   = "roles/compute.xpnAdmin"
  member = "serviceAccount:${var.stage0_automation_service_accounts.networking}"
}

# Project Creator on the Networking folder
resource "google_folder_iam_member" "network_sa_project_creator" {
  folder = google_folder.networking.name
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${var.stage0_automation_service_accounts.networking}"
}

# Folder Admin within the Networking folder
resource "google_folder_iam_member" "network_sa_folder_admin" {
  folder = google_folder.networking.name
  role   = "roles/resourcemanager.folderAdmin"
  member = "serviceAccount:${var.stage0_automation_service_accounts.networking}"
}

# Human Network Administrators Group Access
resource "google_folder_iam_member" "network_admins_viewer" {
  folder = google_folder.networking.name
  role   = "roles/resourcemanager.folderViewer"
  member = var.admin_principals.network_admins
}

# -----------------------------------------------------------------------------
# Security Branch IAM Delegation (Stage 2 Security Automation)
# -----------------------------------------------------------------------------

# Project Creator on the Security folder
resource "google_folder_iam_member" "security_sa_project_creator" {
  folder = google_folder.security.name
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${var.stage0_automation_service_accounts.security}"
}

# Folder Admin within the Security folder
resource "google_folder_iam_member" "security_sa_folder_admin" {
  folder = google_folder.security.name
  role   = "roles/resourcemanager.folderAdmin"
  member = "serviceAccount:${var.stage0_automation_service_accounts.security}"
}

# Cloud KMS Admin for CMEK and cryptographic keys
resource "google_folder_iam_member" "security_sa_kms_admin" {
  folder = google_folder.security.name
  role   = "roles/cloudkms.admin"
  member = "serviceAccount:${var.stage0_automation_service_accounts.security}"
}

# Human Security Administrators Group Access
resource "google_folder_iam_member" "security_admins_viewer" {
  folder = google_folder.security.name
  role   = "roles/resourcemanager.folderViewer"
  member = var.admin_principals.security_admins
}

# -----------------------------------------------------------------------------
# Workloads Branch IAM Delegation (Project Factory Automation)
# -----------------------------------------------------------------------------

# Project Creator on Workloads Root
resource "google_folder_iam_member" "pf_sa_project_creator" {
  folder = google_folder.workloads.name
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${var.stage0_automation_service_accounts.project_factory}"
}

# Folder Admin within Workloads (allows creating team/app subfolders)
resource "google_folder_iam_member" "pf_sa_folder_admin" {
  folder = google_folder.workloads.name
  role   = "roles/resourcemanager.folderAdmin"
  member = "serviceAccount:${var.stage0_automation_service_accounts.project_factory}"
}

# Human DevOps/Platform Team Access
resource "google_folder_iam_member" "devops_admins_viewer" {
  folder = google_folder.workloads.name
  role   = "roles/resourcemanager.folderViewer"
  member = var.admin_principals.devops_admins
}
