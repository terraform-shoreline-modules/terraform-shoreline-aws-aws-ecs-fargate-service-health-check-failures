resource "shoreline_notebook" "troubleshooting_ecs_fargate_service_health_check_failures" {
  name       = "troubleshooting_ecs_fargate_service_health_check_failures"
  data       = file("${path.module}/data/troubleshooting_ecs_fargate_service_health_check_failures.json")
  depends_on = [shoreline_action.invoke_ecs_describe_tasks_containers_info,shoreline_action.invoke_update_task_definition]
}

resource "shoreline_file" "ecs_describe_tasks_containers_info" {
  name             = "ecs_describe_tasks_containers_info"
  input_file       = "${path.module}/data/ecs_describe_tasks_containers_info.sh"
  md5              = filemd5("${path.module}/data/ecs_describe_tasks_containers_info.sh")
  description      = "7. Check the status and configuration of the application in the ECS Fargate container"
  destination_path = "/tmp/ecs_describe_tasks_containers_info.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_task_definition" {
  name             = "update_task_definition"
  input_file       = "${path.module}/data/update_task_definition.sh"
  md5              = filemd5("${path.module}/data/update_task_definition.sh")
  description      = "Compare the port mappings of your task definitions match the ports of your target groups and update the task definition"
  destination_path = "/tmp/update_task_definition.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_ecs_describe_tasks_containers_info" {
  name        = "invoke_ecs_describe_tasks_containers_info"
  description = "7. Check the status and configuration of the application in the ECS Fargate container"
  command     = "`chmod +x /tmp/ecs_describe_tasks_containers_info.sh && /tmp/ecs_describe_tasks_containers_info.sh`"
  params      = ["TASK_ID","CLUSTER_NAME"]
  file_deps   = ["ecs_describe_tasks_containers_info"]
  enabled     = true
  depends_on  = [shoreline_file.ecs_describe_tasks_containers_info]
}

resource "shoreline_action" "invoke_update_task_definition" {
  name        = "invoke_update_task_definition"
  description = "Compare the port mappings of your task definitions match the ports of your target groups and update the task definition"
  command     = "`chmod +x /tmp/update_task_definition.sh && /tmp/update_task_definition.sh`"
  params      = ["SERVICE_NAME","TARGET_GROUP_ARN","CLUSTER_NAME"]
  file_deps   = ["update_task_definition"]
  enabled     = true
  depends_on  = [shoreline_file.update_task_definition]
}

