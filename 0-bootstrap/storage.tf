/**
 * Google FAST Stage 0: Terraform State Storage
 * Provisions dedicated, isolated Cloud Storage buckets for each FAST stage,
 * enabling versioning, uniform bucket-level access, and least-privilege state access.
 */

locals {
  state_stages = {
    stage0 = {
      suffix = "stage0-bootstrap"
      sa_key = null
    }
    stage1 = {
      suffix = "stage1-resman"
      sa_key = "resman"
    }
    stage2_networking = {
      suffix = "stage2-networking"
      sa_key = "networking"
    }
    stage2_security = {
      suffix = "stage2-security"
      sa_key = "security"
    }
    stage2_project_factory = {
      suffix = "stage2-project-factory"
      sa_key = "project_factory"
    }
  }
}

# -----------------------------------------------------------------------------
# Stage State Buckets
# -----------------------------------------------------------------------------

resource "google_storage_bucket" "state_buckets" {
  for_each = local.state_stages

  name                        = "${var.prefix}-state-${each.value.suffix}-${random_string.project_suffix.result}"
  project                     = google_project.automation.project_id
  location                    = var.storage_location
  uniform_bucket_level_access = true
  force_destroy               = false
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  labels = {
    environment = "prod"
    stage       = each.value.suffix
    managed_by  = "terraform-fast"
  }

  depends_on = [
    google_project_service.services["storage.googleapis.com"]
  ]
}

# -----------------------------------------------------------------------------
# Least-Privilege State Bucket Access for Stage SAs
# Grants each stage automation SA objectAdmin rights only on its own state bucket
# -----------------------------------------------------------------------------

resource "google_storage_bucket_iam_member" "sa_state_access" {
  for_each = {
    for k, v in local.state_stages : k => v
    if v.sa_key != null
  }

  bucket = google_storage_bucket.state_buckets[each.key].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.stage_sas[each.value.sa_key].email}"
}
