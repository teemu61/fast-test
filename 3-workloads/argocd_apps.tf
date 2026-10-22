/**
 * Google FAST Stage 3: ArgoCD Application Bootstrap
 *
 * Defines the GitOps root Application CRD via kubernetes_manifest.
 * Connects ArgoCD to the hello-world-config repository with automated sync,
 * pruning, self-healing, and environment-driven value files.
 */

resource "kubernetes_manifest" "argocd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = local.argocd_app_name
      namespace = "argocd"
      labels = {
        environment = local.environment
        managed-by  = "terraform-fast"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_repo_revision
        path           = var.gitops_repo_path
        helm = {
          valueFiles = [
            "values-${local.environment}.yaml"
          ]
          parameters = [
            {
              name  = "global.projectId"
              value = google_project.workload.project_id
            },
            {
              name  = "global.environment"
              value = local.environment
            },
            {
              name  = "global.prefix"
              value = var.prefix
            },
            {
              name  = "backendConfig.securityPolicyName"
              value = google_compute_security_policy.cloud_armor.name
            },
            {
              name  = "ingress.staticIpName"
              value = google_compute_global_address.gke_ingress_ip.name
            },
            {
              name  = "externalSecret.remoteKey"
              value = google_secret_manager_secret.db_password.secret_id
            }
          ]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "${var.prefix}-${local.environment}-app"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    helm_release.external_secrets
  ]
}
