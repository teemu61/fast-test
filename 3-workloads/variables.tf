/**
 * Google FAST Stage 3: Workloads (Cloud Run Application)
 * Input variables consumable from Stage 1 contracts or standalone tfvars.
 */

# -----------------------------------------------------------------------------
# Stage 1 Contract Inputs (folder_id, billing_account_id, automation_sa)
# These match the keys output by Stage 1's stage2_project_factory_inputs.
# -----------------------------------------------------------------------------

variable "folder_id" {
  description = "Resource ID of the Workloads folder created in Stage 1 (e.g. 'folders/1234567890')."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID to associate with the workload application project."
  type        = string
}

variable "automation_sa" {
  description = "Service account provisioned for Stage 3 Workloads deployment (fast-stage2-pf)."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Workload Project Configuration
# -----------------------------------------------------------------------------

variable "prefix" {
  description = "Prefix prepended to resource names to enforce FAST naming standards."
  type        = string
  default     = "fast"
}

variable "environment" {
  description = "Environment identifier ('dev', 'prod', 'staging')."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Google Cloud region where the Cloud Run service is deployed."
  type        = string
  default     = "europe-west1"
}

variable "project_id" {
  description = "Custom Project ID for the workload application project. If null, a deterministic FAST ID is generated."
  type        = string
  default     = null
}

variable "project_services" {
  description = "List of Google Cloud APIs to enable on the workload application project."
  type        = list(string)
  default = [
    "run.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

# -----------------------------------------------------------------------------
# Cloud Run Application & Container Configuration
# -----------------------------------------------------------------------------

variable "container_image" {
  description = "Container image to deploy on Cloud Run. Defaults to an HTTP-compatible hello-world server. Note: Docker Hub's CLI hello-world (docker.io/library/hello-world) exits immediately (code 0) without binding to PORT, so an HTTP server is required for Cloud Run."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "docker_hub_image_reference" {
  description = "Reference to the requested Docker Hub hello-world image (e.g. 'docker.io/library/hello-world' or 'docker.io/nginxdemos/hello')."
  type        = string
  default     = "https://hub.docker.com/_/hello-world"
}

variable "allow_unauthenticated" {
  description = "Whether to allow public, unauthenticated access (allUsers) to the Cloud Run service."
  type        = bool
  default     = true
}

variable "invoker_members" {
  description = "List of IAM principals allowed to invoke the Cloud Run service if allow_unauthenticated is false."
  type        = list(string)
  default     = []
}

variable "min_instance_count" {
  description = "Minimum number of container instances (0 scales down to zero when idle)."
  type        = number
  default     = 0
}

variable "max_instance_count" {
  description = "Maximum number of container instances to auto-scale."
  type        = number
  default     = 5
}

variable "cpu" {
  description = "CPU allocated per container instance (e.g. '1', '2')."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory allocated per container instance (e.g. '512Mi', '1Gi')."
  type        = string
  default     = "512Mi"
}

# -----------------------------------------------------------------------------
# Declarative YAML Configuration File
# -----------------------------------------------------------------------------

variable "app_config_file" {
  description = "Path to the declarative application YAML configuration file relative to the module root."
  type        = string
  default     = "data/hello-world.yaml"
}

