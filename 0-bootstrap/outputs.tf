/**
 * Google FAST Stage 0: Bootstrap Outputs
 * Exports seed project details, remote state buckets, stage service account emails,
 * and the Stage 1 contract consumable by Resource Management (1-resman).
 */

output "automation_project_id" {
  description = "Project ID of the seed automation project."
  value       = google_project.automation.project_id
}

output "automation_project_number" {
  description = "Project number of the seed automation project."
  value       = google_project.automation.number
}

output "state_buckets" {
  description = "Terraform remote state Cloud Storage bucket names per stage."
  value = {
    for k, b in google_storage_bucket.state_buckets : k => b.name
  }
}

output "stage0_automation_service_accounts" {
  description = "Emails of the dedicated stage automation service accounts."
  value = {
    resman          = google_service_account.stage_sas["resman"].email
    networking      = google_service_account.stage_sas["networking"].email
    security        = google_service_account.stage_sas["security"].email
    project_factory = google_service_account.stage_sas["project_factory"].email
  }
}

# -----------------------------------------------------------------------------
# FAST Stage Contracts: Outputs consumable by Stage 1 (1-resman)
# -----------------------------------------------------------------------------

output "stage1_resman_inputs" {
  description = "Stage 1 contract object containing organization, billing, and automation SA inputs."
  value = {
    organization_id    = var.organization_id
    billing_account_id = var.billing_account_id
    prefix             = var.prefix
    stage0_automation_service_accounts = {
      resman          = google_service_account.stage_sas["resman"].email
      networking      = google_service_account.stage_sas["networking"].email
      security        = google_service_account.stage_sas["security"].email
      project_factory = google_service_account.stage_sas["project_factory"].email
    }
    admin_principals = var.admin_principals
  }
}
