# -----------------------------------------------------------------------------
# Google Cloud Foundation Fabric (FAST) - Stage 3 (Workloads) Configuration
# -----------------------------------------------------------------------------

# Workloads folder ID (Dev or Prod folder from Stage 1: 1-resman)
folder_id          = "folders/123456789012"
billing_account_id = "012345-6789AB-CDEF01"
automation_sa      = "fast-stage2-pf@fast-prod-iac-0.iam.gserviceaccount.com"

prefix = "fast"

# Path to the declarative application YAML configuration
# All application-specific settings (container image, scaling, cpu/memory, env)
# are defined in data/hello-world.yaml.
app_config_file = "data/hello-world.yaml"
