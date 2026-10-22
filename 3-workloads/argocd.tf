/**
 * Google FAST Stage 3: ArgoCD GitOps Controller
 *
 * Configures the Helm and Kubernetes providers using ephemeral OAuth2 access tokens
 * obtained from google_client_config, and installs ArgoCD into the dedicated 'argocd' namespace.
 */

# -----------------------------------------------------------------------------
# Kubernetes & Helm Provider Authentication for GKE Autopilot
# -----------------------------------------------------------------------------

data "google_client_config" "default" {}

provider "helm" {
  kubernetes = {
    host                   = "https://${google_container_cluster.autopilot.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.autopilot.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate)
}

# -----------------------------------------------------------------------------
# ArgoCD Helm Installation
# -----------------------------------------------------------------------------

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_helm_version
  namespace        = "argocd"
  create_namespace = true

  # GKE Autopilot and security-compatible configuration values using yamlencode
  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
      configs = {
        params = {
          "server.insecure" = "true"
        }
      }
      controller = {
        enableStatefulSet = false
      }
    })
  ]

  depends_on = [
    google_container_cluster.autopilot
  ]
}
