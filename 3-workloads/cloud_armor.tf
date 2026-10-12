/**
 * Google FAST Stage 3: Cloud Armor Security Policy
 * Configures Cloud Armor WAF, Rate Limiting, and preconfigured OWASP rules
 * driven by declarative YAML (data/cloud_armor.yaml).
 */

# -----------------------------------------------------------------------------
# Cloud Armor Security Policy
# -----------------------------------------------------------------------------

resource "google_compute_security_policy" "cloud_armor" {
  name        = local.security_policy_name
  project     = google_project.workload.project_id
  description = local.security_policy_description

  # Dynamic rule generation parsed from data/cloud_armor.yaml
  dynamic "rule" {
    for_each = local.security_policy_rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = try(rule.value.description, null)
      preview     = try(rule.value.preview, false)

      # Layer 7 CEL Expression matching (e.g. preconfigured OWASP rules)
      dynamic "match" {
        for_each = try(rule.value.expression, null) != null ? [rule.value.expression] : []
        content {
          expr {
            expression = match.value
          }
        }
      }

      # IP CIDR matching (e.g. rate limiting or default rule)
      dynamic "match" {
        for_each = try(rule.value.src_ip_ranges, null) != null ? [rule.value.src_ip_ranges] : []
        content {
          versioned_expr = "SRC_IPS_V1"
          config {
            src_ip_ranges = match.value
          }
        }
      }

      # Rate Limiting configuration options
      dynamic "rate_limit_options" {
        for_each = try(rule.value.rate_limit_options, null) != null ? [rule.value.rate_limit_options] : []
        content {
          conform_action   = rate_limit_options.value.conform_action
          exceed_action    = rate_limit_options.value.exceed_action
          enforce_on_key   = try(rate_limit_options.value.enforce_on_key, "IP")
          ban_duration_sec = try(rate_limit_options.value.ban_duration_sec, null)

          rate_limit_threshold {
            count        = rate_limit_options.value.rate_limit_threshold_count
            interval_sec = rate_limit_options.value.rate_limit_threshold_interval_sec
          }
        }
      }
    }
  }

  depends_on = [google_project_service.services]
}
