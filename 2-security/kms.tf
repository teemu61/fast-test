/**
 * Google FAST Stage 2: Cloud KMS (Key Management Service)
 * Provisions regional Key Rings and Customer-Managed Encryption Keys (CMEK)
 * with automated key rotation for workloads (compute, storage, bigquery, gke).
 */

# -----------------------------------------------------------------------------
# Regional Key Rings
# -----------------------------------------------------------------------------

resource "google_kms_key_ring" "key_rings" {
  for_each = toset(var.kms_regions)

  name     = "${var.prefix}-${var.environment}-kr-${each.value}"
  location = each.value
  project  = google_project.security_project.project_id

  depends_on = [
    google_project_service.services["cloudkms.googleapis.com"]
  ]
}

# -----------------------------------------------------------------------------
# Customer-Managed Encryption Keys (CMEK)
# -----------------------------------------------------------------------------

locals {
  region_key_combinations = merge([
    for region in var.kms_regions : {
      for purpose in var.kms_key_purposes :
      "${region}/${purpose}" => {
        region  = region
        purpose = purpose
      }
    }
  ]...)
}

resource "google_kms_crypto_key" "keys" {
  for_each = local.region_key_combinations

  name            = "${var.prefix}-${var.environment}-key-${each.value.purpose}"
  key_ring        = google_kms_key_ring.key_rings[each.value.region].id
  rotation_period = var.key_rotation_period
  purpose         = "ENCRYPT_DECRYPT"

  labels = {
    environment = var.environment
    purpose     = each.value.purpose
    managed_by  = "terraform-fast"
  }
}
