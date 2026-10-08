/**
 * Google FAST Stage 0: IAM Configuration
 * Provisions dedicated stage automation service accounts, grants organization
 * and billing permissions, and configures impersonation for human/CI administrators.
 */

locals {
  stage_service_accounts = {
    resman = {
      account_id   = "${var.prefix}-stage1-resman"
      display_name = "FAST Stage 1 (Resource Management) Service Account"
      description  = "Manages folder hierarchies, organization policies, and hierarchical tags"
    }
    networking = {
      account_id   = "${var.prefix}-stage2-net"
      display_name = "FAST Stage 2 (Networking) Service Account"
      description  = "Manages Shared VPC host projects, networks, subnets, routers, and firewalls"
    }
    security = {
      account_id   = "${var.prefix}-stage2-sec"
      display_name = "FAST Stage 2 (Security) Service Account"
      description  = "Manages centralized KMS keys, Certificate Authority Service, and Secret Manager"
    }
    project_factory = {
      account_id   = "${var.prefix}-stage2-pf"
      display_name = "FAST Stage 2/3 (Project Factory) Service Account"
      description  = "Provisions workload application projects and binds them to Shared VPCs"
    }
  }

  org_roles = {
    "resman:org_admin"     = { sa = "resman", role = "roles/resourcemanager.organizationAdmin" }
    "resman:folder_admin"  = { sa = "resman", role = "roles/resourcemanager.folderAdmin" }
    "resman:tag_admin"     = { sa = "resman", role = "roles/resourcemanager.tagAdmin" }
    "resman:policy_admin"  = { sa = "resman", role = "roles/orgpolicy.policyAdmin" }
    "networking:xpn_admin" = { sa = "networking", role = "roles/compute.xpnAdmin" }
  }
}

# -----------------------------------------------------------------------------
# Stage Automation Service Accounts
# -----------------------------------------------------------------------------

resource "google_service_account" "stage_sas" {
  for_each = local.stage_service_accounts

  project      = google_project.automation.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}

# -----------------------------------------------------------------------------
# Organization-Level IAM Roles
# -----------------------------------------------------------------------------

resource "google_organization_iam_member" "org_roles" {
  for_each = var.grant_org_roles ? local.org_roles : {}

  org_id = var.organization_id
  role   = each.value.role
  member = "serviceAccount:${google_service_account.stage_sas[each.value.sa].email}"
}

# -----------------------------------------------------------------------------
# Billing Account IAM Roles
# Allows stage automation service accounts to associate projects with billing
# -----------------------------------------------------------------------------

resource "google_billing_account_iam_member" "billing_user" {
  for_each = var.grant_billing_roles ? google_service_account.stage_sas : {}

  billing_account_id = var.billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${each.value.email}"
}

# -----------------------------------------------------------------------------
# SA Impersonation Rights (Token Creator)
# Enables admin groups / CI runners to assume stage SA credentials without keys
# -----------------------------------------------------------------------------

resource "google_service_account_iam_member" "impersonation" {
  for_each = google_service_account.stage_sas

  service_account_id = each.value.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = coalesce(var.admin_principals.org_admins, "group:gcp-organization-admins@example.com")
}
