/**
 * Google FAST Stage 3: Kubernetes Manifest Generator
 * Dynamically renders Kubernetes manifests with accurate FAST resource names,
 * static IP references, Cloud Armor security policies, and container configuration.
 */

resource "local_file" "k8s_manifests" {
  count    = var.enable_gke ? 1 : 0
  filename = "${path.module}/k8s/manifests.yaml"
  content  = <<-EOT
---
# =============================================================================
# Google Cloud Armor Integration via GKE BackendConfig
# =============================================================================
apiVersion: networking.gke.io/v1
kind: BackendConfig
metadata:
  name: ${local.gke_backend_config_name}
  labels:
    app: ${local.app_name}
    managed-by: terraform-fast
spec:
  securityPolicy:
    name: ${google_compute_security_policy.cloud_armor.name}

---
# =============================================================================
# Hello World Deployment
# =============================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${local.app_name}
  labels:
    app: ${local.app_name}
    environment: ${local.environment}
    managed-by: terraform-fast
spec:
  replicas: ${var.gke_app_replicas}
  selector:
    matchLabels:
      app: ${local.app_name}
  template:
    metadata:
      labels:
        app: ${local.app_name}
    spec:
      containers:
      - name: ${local.app_name}
        image: ${var.gke_app_image}
        ports:
        - name: http
          containerPort: ${local.container_port}
        resources:
          requests:
            cpu: "50m"
            memory: "64Mi"
          limits:
            cpu: "250m"
            memory: "128Mi"
        livenessProbe:
          httpGet:
            path: /
            port: ${local.container_port}
          initialDelaySeconds: 5
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: ${local.container_port}
          initialDelaySeconds: 5
          periodSeconds: 5

---
# =============================================================================
# Hello World Service (Container-native NEG for GKE Ingress)
# =============================================================================
apiVersion: v1
kind: Service
metadata:
  name: ${local.app_name}
  labels:
    app: ${local.app_name}
    managed-by: terraform-fast
  annotations:
    cloud.google.com/neg: '{"ingress": true}'
    cloud.google.com/backend-config: '{"default": "${local.gke_backend_config_name}"}'
spec:
  type: ClusterIP
  selector:
    app: ${local.app_name}
  ports:
  - name: http
    port: 8080
    targetPort: ${local.container_port}
    protocol: TCP

---
# =============================================================================
# External HTTP Application Load Balancer Ingress
# =============================================================================
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${local.gke_ingress_name}
  labels:
    app: ${local.app_name}
    managed-by: terraform-fast
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "${google_compute_global_address.gke_ingress_ip[0].name}"
spec:
  rules:
  - http:
      paths:
      - path: /*
        pathType: ImplementationSpecific
        backend:
          service:
            name: ${local.app_name}
            port:
              number: 8080
EOT
}
