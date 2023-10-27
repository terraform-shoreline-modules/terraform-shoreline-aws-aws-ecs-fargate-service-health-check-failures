terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "troubleshooting_ecs_fargate_service_health_check_failures" {
  source    = "./modules/troubleshooting_ecs_fargate_service_health_check_failures"

  providers = {
    shoreline = shoreline
  }
}