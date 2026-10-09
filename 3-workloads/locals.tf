/**
 * Google FAST Stage 3: Configuration Parser
 * Decodes and merges declarative application parameters from YAML data files (data/*.yaml).
 */

locals {
  # Parse YAML application definition from the specified YAML file
  app_yaml = fileexists("${path.module}/${var.app_config_file}") ? yamldecode(file("${path.module}/${var.app_config_file}")) : {}

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

  # Dynamic environment variables from YAML
  env_vars = try(local.app_yaml.env, {})
}
