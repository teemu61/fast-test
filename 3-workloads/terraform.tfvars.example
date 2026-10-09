# -----------------------------------------------------------------------------
# Google Cloud Foundation Fabric (FAST) - Stage 3 (Workloads) Configuration
# -----------------------------------------------------------------------------

# Workloads folder ID (Dev or Prod folder from Stage 1: 1-resman)
folder_id          = "folders/123456789012"
billing_account_id = "012345-6789AB-CDEF01"
automation_sa      = "fast-stage2-pf@fast-prod-iac-0.iam.gserviceaccount.com"

prefix      = "fast"
environment = "dev"
region      = "europe-west1"

# Container configuration:
# Note: Cloud Run requires an HTTP web server listening on port 8080.
# The CLI hello-world binary from Docker Hub (https://hub.docker.com/_/hello-world)
# prints a text message and immediately terminates (exit 0).
# For web service workloads, us-docker.pkg.dev/cloudrun/container/hello or
# docker.io/nginxdemos/hello is recommended.
container_image            = "us-docker.pkg.dev/cloudrun/container/hello"
docker_hub_image_reference = "https://hub.docker.com/_/hello-world"

# Access settings
allow_unauthenticated = true

# Instance scaling
min_instance_count = 0
max_instance_count = 5
cpu                = "1"
memory             = "512Mi"
