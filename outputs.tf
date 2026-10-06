/**
 * Google FAST Stage 1: Outputs
 * Exports resource IDs and configuration contracts required by Stage 2
 * (2-networking, 2-security, 2-project-factory).
 */

output "folder_ids" {
  description = "IDs of all created folders in the resource hierarchy."
  value = {
    networking     = google_folder.networking.id
    security       = google_folder.security.id
    common         = google_folder.common.id
    workloads      = google_folder.workloads.id
    workloads_dev  = google_folder.workloads_dev.id
    workloads_prod = google_folder.workloads_prod.id
  }
}

output "folder_names" {
  description = "Display names of all created folders."
  value = {
    networking     = google_folder.networking.display_name
    security       = google_folder.security.display_name
    common         = google_folder.common.display_name
    workloads      = google_folder.workloads.display_name
    workloads_dev  = google_folder.workloads_dev.display_name
    workloads_prod = google_folder.workloads_prod.display_name
  }
}

output "tags" {
  description = "Resource manager tag keys and values created."
  value = var.enable_tags ? {
    keys = {
      context     = google_tags_tag_key.context[0].id
      environment = google_tags_tag_key.environment[0].id
    }
    values = {
      context_networking = google_tags_tag_value.context_networking[0].id
      context_security   = google_tags_tag_value.context_security[0].id
      context_workloads  = google_tags_tag_value.context_workloads[0].id
      env_development    = google_tags_tag_value.env_development[0].id
      env_production     = google_tags_tag_value.env_production[0].id
    }
  } : null
}

# -----------------------------------------------------------------------------
# FAST Stage Contracts: Outputs consumable by Stage 2 stages
# -----------------------------------------------------------------------------

output "stage2_networking_inputs" {
  description = "Inputs intended to be passed into Stage 2 (2-networking)."
  value = {
    folder_id          = google_folder.networking.id
    automation_sa      = var.stage0_automation_service_accounts.networking
    billing_account_id = var.billing_account_id
  }
}

output "stage2_security_inputs" {
  description = "Inputs intended to be passed into Stage 2 (2-security)."
  value = {
    folder_id          = google_folder.security.id
    automation_sa      = var.stage0_automation_service_accounts.security
    billing_account_id = var.billing_account_id
  }
}

output "stage2_project_factory_inputs" {
  description = "Inputs intended to be passed into Stage 2 (2-project-factory)."
  value = {
    workload_folder_ids = {
      dev  = google_folder.workloads_dev.id
      prod = google_folder.workloads_prod.id
    }
    automation_sa      = var.stage0_automation_service_accounts.project_factory
    billing_account_id = var.billing_account_id
  }
}
