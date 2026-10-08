# -----------------------------------------------------------------------------
# Google Cloud Foundation Fabric (FAST) - Stage 2 (Networking) Configuration
# -----------------------------------------------------------------------------

folder_id          = "folders/123456789012"
billing_account_id = "012345-6789AB-CDEF01"
automation_sa      = "fast-stage2-net@fast-prod-iac-0.iam.gserviceaccount.com"

prefix      = "fast"
environment = "prod"

# Feature toggles
enable_cloud_nat         = true
enable_baseline_firewall = true
enable_private_dns       = true
dns_domain               = "gcp.internal."
