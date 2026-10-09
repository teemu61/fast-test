/**
 * Google FAST Stage 3: Cloud Run Serverless Application
 * Deploys the Hello World container service, runtime service account,
 * and IAM invoker bindings configured from declarative YAML (data/*.yaml).
 */

# -----------------------------------------------------------------------------
# Runtime Service Account for Cloud Run (Least Privilege)
# -----------------------------------------------------------------------------

resource "google_service_account" "cloud_run_sa" {
  project      = google_project.workload.project_id
  account_id   = "${var.prefix}-${local.environment}-hello-run-sa"
  display_name = "Cloud Run Hello World Runtime SA"
  description  = "Dedicated runtime service account for the hello-world Cloud Run service"

  depends_on = [google_project_service.services]
}

# -----------------------------------------------------------------------------
# Cloud Run v2 Service
# -----------------------------------------------------------------------------

resource "google_cloud_run_v2_service" "hello_world" {
  name     = "${var.prefix}-${local.environment}-${local.app_name}"
  location = local.region
  project  = google_project.workload.project_id

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run_sa.email

    scaling {
      min_instance_count = local.min_instances
      max_instance_count = local.max_instances
    }

    containers {
      image = local.container_image

      resources {
        limits = {
          cpu    = local.cpu
          memory = local.memory
        }
      }

      ports {
        container_port = local.container_port
      }

      # Static tracking environment variable for the requested Docker Hub reference
      env {
        name  = "DOCKER_HUB_IMAGE"
        value = local.docker_hub_ref
      }

      # Dynamic environment variables defined in the YAML file
      dynamic "env" {
        for_each = local.env_vars
        content {
          name  = env.key
          value = tostring(env.value)
        }
      }
    }
  }

  depends_on = [
    google_project_service.services,
    google_service_account.cloud_run_sa
  ]
}

# -----------------------------------------------------------------------------
# Cloud Run Invoker IAM Permissions
# -----------------------------------------------------------------------------

# Public unauthenticated access (when allow_unauthenticated = true)
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count    = local.allow_unauthenticated ? 1 : 0
  project  = google_cloud_run_v2_service.hello_world.project
  location = google_cloud_run_v2_service.hello_world.location
  name     = google_cloud_run_v2_service.hello_world.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Scoped principal access (when allow_unauthenticated = false)
resource "google_cloud_run_v2_service_iam_member" "authenticated_access" {
  for_each = local.allow_unauthenticated ? toset([]) : toset(var.invoker_members)
  project  = google_cloud_run_v2_service.hello_world.project
  location = google_cloud_run_v2_service.hello_world.location
  name     = google_cloud_run_v2_service.hello_world.name
  role     = "roles/run.invoker"
  member   = each.value
}

