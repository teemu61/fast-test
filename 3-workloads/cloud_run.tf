/**
 * Google FAST Stage 3: Cloud Run Serverless Application
 * Deploys the Hello World container service, runtime service account,
 * and IAM invoker bindings.
 */

# -----------------------------------------------------------------------------
# Runtime Service Account for Cloud Run (Least Privilege)
# -----------------------------------------------------------------------------

resource "google_service_account" "cloud_run_sa" {
  project      = google_project.workload.project_id
  account_id   = "${var.prefix}-${var.environment}-hello-run-sa"
  display_name = "Cloud Run Hello World Runtime SA"
  description  = "Dedicated runtime service account for the hello-world Cloud Run service"

  depends_on = [google_project_service.services]
}

# -----------------------------------------------------------------------------
# Cloud Run v2 Service
# -----------------------------------------------------------------------------

resource "google_cloud_run_v2_service" "hello_world" {
  name     = "${var.prefix}-${var.environment}-hello-world"
  location = var.region
  project  = google_project.workload.project_id

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run_sa.email

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }

    containers {
      image = var.container_image

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      ports {
        container_port = 8080
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
      env {
        name  = "DOCKER_HUB_IMAGE"
        value = var.docker_hub_image_reference
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
  count    = var.allow_unauthenticated ? 1 : 0
  project  = google_cloud_run_v2_service.hello_world.project
  location = google_cloud_run_v2_service.hello_world.location
  name     = google_cloud_run_v2_service.hello_world.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Scoped principal access (when allow_unauthenticated = false)
resource "google_cloud_run_v2_service_iam_member" "authenticated_access" {
  for_each = var.allow_unauthenticated ? toset([]) : toset(var.invoker_members)
  project  = google_cloud_run_v2_service.hello_world.project
  location = google_cloud_run_v2_service.hello_world.location
  name     = google_cloud_run_v2_service.hello_world.name
  role     = "roles/run.invoker"
  member   = each.value
}
