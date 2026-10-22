/**
 * Google FAST Stage 3: External Secrets Operator & Secret Manager Integration
 *
 * Deploys the External Secrets Operator (ESO) Helm chart, creates a dedicated GCP Service
 * Account with Secret Manager Secret Accessor permissions, binds Workload Identity,
 * and creates a demo Secret Manager secret (fast-dev-db-password).
 */

# -----------------------------------------------------------------------------
# Dedicated GCP Service Account for External Secrets Operator (ESO)
# -----------------------------------------------------------------------------

resource "google_service_account" "eso_sa" {
  account_id   = local.eso_sa_id
  project      = google_project.workload.project_id
  display_name = "External Secrets Operator Service Account (${local.eso_sa_id})"

  depends_on = [google_project_service.services]
}

# Grant Secret Accessor permission to ESO GCP Service Account
resource "google_project_iam_member" "eso_secret_accessor" {
  project = google_project.workload.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_sa.email}"
}

# -----------------------------------------------------------------------------
# Workload Identity Binding (Keyless Authentication)
# -----------------------------------------------------------------------------

# Bind Kubernetes service account 'external-secrets' in namespace 'external-secrets'
# to the GCP service account via Workload Identity
resource "google_service_account_iam_member" "eso_workload_identity" {
  service_account_id = google_service_account.eso_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${google_project.workload.project_id}.svc.id.goog[external-secrets/external-secrets]"
}

# -----------------------------------------------------------------------------
# External Secrets Operator (ESO) Helm Release
# -----------------------------------------------------------------------------

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.eso_helm_version
  namespace        = "external-secrets"
  create_namespace = true

  # Declarative configuration values using yamlencode
  values = [
    yamlencode({
      installCRDs = true
      serviceAccount = {
        create = true
        name   = "external-secrets"
        annotations = {
          "iam.gke.io/gcp-service-account" = google_service_account.eso_sa.email
        }
      }
    })
  ]

  depends_on = [
    google_container_cluster.autopilot,
    google_service_account_iam_member.eso_workload_identity
  ]
}

# -----------------------------------------------------------------------------
# Demo Secret in GCP Secret Manager (FAST Standard Naming)
# -----------------------------------------------------------------------------

resource "google_secret_manager_secret" "db_password" {
  secret_id = local.db_secret_id
  project   = google_project.workload.project_id

  replication {
    auto {}
  }

  labels = {
    environment = local.environment
    managed_by  = "terraform-fast"
    workload    = local.app_name
  }

  depends_on = [google_project_service.services]
}

resource "google_secret_manager_secret_version" "db_password_val" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = "FAST-P@ssw0rd-${local.environment}-SecureToken2026!"
}
