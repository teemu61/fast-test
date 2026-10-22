#!/usr/bin/env bash
# =============================================================================
# Google FAST Stage 3: Kubernetes Workload Deployment Helper
# Deploys the Hello World application to GKE and verifies Ingress programming.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "==> [1/4] Luetaan Terraform-tulosteet..."
PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || true)
CLUSTER_NAME=$(terraform output -raw gke_cluster_name 2>/dev/null || true)
CLUSTER_ZONE=$(terraform output -raw gke_cluster_location 2>/dev/null || true)
INGRESS_IP=$(terraform output -raw gke_ingress_ip 2>/dev/null || true)

if [[ -z "${PROJECT_ID}" || -z "${CLUSTER_NAME}" || "${CLUSTER_NAME}" == "null" ]]; then
  echo "Virhe: GKE-klusterin tietoja ei löytynyt Terraform-tulosteista."
  echo "Varmista, että 'terraform apply' on suoritettu onnistuneesti hakemistossa 3-workloads/."
  exit 1
fi

echo "    Projekti:       ${PROJECT_ID}"
echo "    Klusteri:       ${CLUSTER_NAME}"
echo "    Vyöhyke:        ${CLUSTER_ZONE}"
echo "    Varattu IP:     ${INGRESS_IP}"

echo "==> [2/4] Noudetaan Kubernetes-tunnistetiedot (kubeconfig)..."
gcloud container clusters get-credentials "${CLUSTER_NAME}" \
  --zone "${CLUSTER_ZONE}" \
  --project "${PROJECT_ID}"

echo "==> [3/4] Asennetaan Kubernetes-resurssit (Deployment, Service, BackendConfig, Ingress)..."
if [[ -f "${SCRIPT_DIR}/k8s/manifests.yaml" ]]; then
  kubectl apply -f "${SCRIPT_DIR}/k8s/manifests.yaml"
else
  kubectl apply -k "${SCRIPT_DIR}/k8s/"
fi

echo "==> [4/4] Odotetaan kuormantasaajan ja Ingress-resurssin valmistumista..."
echo "Tarkistetaan Ingress-tila (Google Cloud Load Balancerin konfigurointi kestää tyypillisesti 3-5 minuuttia):"
kubectl get ingress

echo ""
echo "Sovellus on julkaistu internetiin osoitteessa:"
echo "http://${INGRESS_IP}/"
echo ""
echo "Voit seurata Ingressin etenemistä komennolla:"
echo "kubectl describe ingress \$(kubectl get ingress -o jsonpath='{.items[0].metadata.name}')"
