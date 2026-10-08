/**
 * Google FAST Stage 2: Security Outputs
 * Exports security core project ID, Cloud KMS keys, Secret Manager resources,
 * and the Stage 3 contract object consumable by downstream application workloads.
 */

output "project_id" {
  description = "Project ID of the centralized security core project."
  value       = google_project.security_project.project_id
}

output "project_number" {
  description = "Project number of the centralized security core project."
  value       = google_project.security_project.number
}

output "kms_key_rings" {
  description = "Map of Cloud KMS key rings by region."
  value = {
    for r, kr in google_kms_key_ring.key_rings : r => kr.id
  }
}

output "kms_keys" {
  description = "Map of Customer-Managed Encryption Keys (CMEK) by region and purpose."
  value = {
    for k, key in google_kms_crypto_key.keys : k => key.id
  }
}

output "secrets" {
  description = "Map of provisioned Secret Manager secret IDs."
  value = {
    for name, s in google_secret_manager_secret.secrets : name => s.id
  }
}

output "ca_pool_id" {
  description = "Identifier of the Private CA Pool if enabled."
  value       = var.enable_ca_service ? google_privateca_ca_pool.ca_pool[0].id : null
}

# -----------------------------------------------------------------------------
# FAST Stage Contracts: Outputs consumable by Stage 3 (Workloads / Project Factory)
# -----------------------------------------------------------------------------

output "stage3_security_inputs" {
  description = "Stage 3 contract object containing CMEK key IDs and CAS references for application encryption."
  value = {
    security_project_id = google_project.security_project.project_id
    kms_keys = {
      for k, key in google_kms_crypto_key.keys : k => key.id
    }
    ca_pool_id = var.enable_ca_service ? google_privateca_ca_pool.ca_pool[0].id : null
  }
}
