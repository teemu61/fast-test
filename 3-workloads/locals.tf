/**
 * Google FAST Stage 3: Configuration Parser
 * Decodes and merges declarative application parameters from YAML data files (data/*.yaml).
 */

locals {
  # Parse YAML application definition from the specified YAML file
  app_yaml = fileexists("${path.module}/${var.app_config_file}") ? yamldecode(file("${path.module}/${var.app_config_file}")) : {}

  # Parse YAML Cloud Armor security policy definition
  armor_yaml = fileexists("${path.module}/${var.cloud_armor_config_file}") ? yamldecode(file("${path.module}/${var.cloud_armor_config_file}")) : {}

  # Workload metadata
  app_name    = try(local.app_yaml.name, "hello-world")
  environment = try(local.app_yaml.environment, var.environment)
  region      = try(local.app_yaml.region, var.region)

  # Container configuration
  container_image = try(local.app_yaml.container.image, var.container_image)
  docker_hub_ref  = try(local.app_yaml.container.docker_hub_reference, var.docker_hub_image_reference)
  container_port  = try(local.app_yaml.container.port, 8080)
  cpu             = try(local.app_yaml.container.resources.cpu, var.cpu)
  memory          = try(local.app_yaml.container.resources.memory, var.memory)

  # Scaling configuration
  min_instances = try(local.app_yaml.scaling.min_instances, var.min_instance_count)
  max_instances = try(local.app_yaml.scaling.max_instances, var.max_instance_count)

  # Access permissions
  allow_unauthenticated = try(local.app_yaml.access.allow_unauthenticated, var.allow_unauthenticated)
  ingress               = try(local.app_yaml.access.ingress, "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER")

  # Dynamic environment variables from YAML
  env_vars = try(local.app_yaml.env, {})

  # ---------------------------------------------------------------------------
  # FAST Naming Standard: ${var.prefix}-${local.environment}-<palvelun_nimi>
  # ---------------------------------------------------------------------------

  # Cloud Run & Service Account
  cloud_run_service_name = "${var.prefix}-${local.environment}-${local.app_name}"
  cloud_run_sa_id        = substr("${var.prefix}-${local.environment}-${local.app_name}-sa", 0, 30)

  # Cloud Armor security policy (try YAML input first, fallback to FAST standard)
  security_policy_name = try(
    local.armor_yaml.security_policy.name,
    null
  ) != null ? local.armor_yaml.security_policy.name : "${var.prefix}-${local.environment}-armor"
  security_policy_description = try(local.armor_yaml.security_policy.description, "Stage 3 Cloud Run Cloud Armor WAF ja Rate Limiting -tietoturvakäytäntö")
  security_policy_rules       = try(local.armor_yaml.security_policy.rules, [])

  # Load Balancer resources
  serverless_neg_name = "${var.prefix}-${local.environment}-${local.app_name}-neg"
  backend_name        = "${var.prefix}-${local.environment}-${local.app_name}-backend"
  url_map_name        = "${var.prefix}-${local.environment}-${local.app_name}-url-map"
  lb_ip_name          = "${var.prefix}-${local.environment}-${local.app_name}-lb-ip"
  http_proxy_name     = "${var.prefix}-${local.environment}-${local.app_name}-http-proxy"
  http_rule_name      = "${var.prefix}-${local.environment}-${local.app_name}-http-rule"
  ssl_cert_name       = "${var.prefix}-${local.environment}-${local.app_name}-cert"
  https_proxy_name    = "${var.prefix}-${local.environment}-${local.app_name}-https-proxy"
  https_rule_name     = "${var.prefix}-${local.environment}-${local.app_name}-https-rule"
}

