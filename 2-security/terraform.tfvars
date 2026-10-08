# -----------------------------------------------------------------------------
# Google Cloud Foundation Fabric (FAST) - Stage 2 (Security) Configuration
# -----------------------------------------------------------------------------

folder_id          = "folders/123456789012"
billing_account_id = "012345-6789AB-CDEF01"
automation_sa      = "fast-stage2-sec@fast-prod-iac-0.iam.gserviceaccount.com"

prefix      = "fast"
environment = "prod"

# Cloud KMS regions and CMEK purposes
kms_regions         = ["europe-west1", "europe-west4"]
kms_key_purposes    = ["compute", "storage", "bigquery", "gke"]
key_rotation_period = "7776000s" # 90 days

# Feature toggles
enable_secret_manager = true
enable_ca_service     = true
ca_pool_tier          = "DEVOPS"
