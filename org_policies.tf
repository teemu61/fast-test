/**
 * Google FAST Stage 1: Organization Policies
 * Sets top-down baseline security guardrails at the GCP Organization root.
 */

# Disable creation of downloadable service account keys (forces Workload Identity / short-lived tokens)
resource "google_org_policy_policy" "disable_sa_key_creation" {
  count  = var.org_policies_enabled ? 1 : 0
  name   = "organizations/${var.organization_id}/policies/iam.disableServiceAccountKeyCreation"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# Disable serial port access to Compute Engine instances
resource "google_org_policy_policy" "disable_serial_port_access" {
  count  = var.org_policies_enabled ? 1 : 0
  name   = "organizations/${var.organization_id}/policies/compute.disableSerialPortAccess"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# Require OS Login for SSH authentication across all Compute Engine instances
resource "google_org_policy_policy" "require_os_login" {
  count  = var.org_policies_enabled ? 1 : 0
  name   = "organizations/${var.organization_id}/policies/compute.requireOsLogin"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# Disable automatic role grants to default service accounts when APIs are enabled
resource "google_org_policy_policy" "disable_default_sa_grants" {
  count  = var.org_policies_enabled ? 1 : 0
  name   = "organizations/${var.organization_id}/policies/iam.automaticIamGrantsForDefaultServiceAccounts"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}
