/**
 * Google FAST Stage 0: Workload Identity Federation (WIF)
 * Provisions a Workload Identity Pool, GitHub OIDC Provider, and delegates
 * roles/iam.workloadIdentityUser to Stage Automation Service Accounts for keyless CI/CD.
 */

# -----------------------------------------------------------------------------
# Workload Identity Pool
# -----------------------------------------------------------------------------

resource "google_iam_workload_identity_pool" "github_pool" {
  count = var.enable_wif ? 1 : 0

  project                   = google_project.automation.project_id
  workload_identity_pool_id = "${var.prefix}-github-pool"
  display_name              = "FAST GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions keyless CI/CD"
}

# -----------------------------------------------------------------------------
# Workload Identity Pool Provider (GitHub OIDC)
# -----------------------------------------------------------------------------

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  count = var.enable_wif ? 1 : 0

  project                            = google_project.automation.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC Provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = var.github_repository != null ? "assertion.repository == '${var.github_repository}'" : null

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# -----------------------------------------------------------------------------
# Workload Identity User Binding on Stage Service Accounts
# Allows GitHub Actions workflows in the specified repository to impersonate stage SAs
# -----------------------------------------------------------------------------

resource "google_service_account_iam_member" "wif_impersonation" {
  for_each = var.enable_wif && var.github_repository != null ? google_service_account.stage_sas : {}

  service_account_id = each.value.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool[0].name}/attribute.repository/${var.github_repository}"
}
