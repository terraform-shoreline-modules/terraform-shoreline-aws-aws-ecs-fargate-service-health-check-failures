
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Troubleshooting ECS Fargate Service Health Check Failures
---

This incident type refers to troubleshooting issues related to blue/green deployments for services hosted on Amazon Elastic Container Service (ECS) Fargate. Specifically, the incident involves ECS service failing to stabilize due to health check failures. The solution involves ensuring that the port mappings of task definitions match the ports of target groups. To troubleshoot load balancer health check issues for ECS Fargate task and pass the Application Load Balancer health check, connectivity between the load balancer and Amazon ECS task, health check settings of the target group, and status and configuration of the application in ECS Fargate container must be checked.

### Parameters
```shell
export CLUSTER_NAME="PLACEHOLDER"

export TASK_ARN="PLACEHOLDER"

export SERVICE_NAME="PLACEHOLDER"

export TARGET_GROUP_ARN="PLACEHOLDER"

export LOG_GROUP_NAME="PLACEHOLDER"

export LOG_STREAM_NAME="PLACEHOLDER"

export LOAD_BALANCER_ARN="PLACEHOLDER"

export TASK_ID="PLACEHOLDER"
```

## Debug

### 1. Check the status of the ECS task
```shell
aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ARN}
```

### 2. Check the status of the ECS service
```shell
aws ecs describe-services --cluster ${CLUSTER_NAME} --services ${SERVICE_NAME}
```

### 3. Check the status of the target group associated with the ECS service
```shell
aws elbv2 describe-target-health --target-group-arn ${TARGET_GROUP_ARN}
```

### 4. Check the logs for the ECS task
```shell
aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name ${LOG_STREAM_NAME}
```

### 5. Check the load balancer configuration
```shell
aws elbv2 describe-load-balancers --load-balancer-arns ${LOAD_BALANCER_ARN}
```

### 6. Check the health check settings for the target group
```shell
aws elbv2 describe-target-group-attributes --target-group-arn ${TARGET_GROUP_ARN}
```

### 7. Check the status and configuration of the application in the ECS Fargate container
```shell
aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ID} --query 'tasks[].containers[].name'

aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ID} --query 'tasks[].containers[].lastStatus'

aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ID} --query 'tasks[].containers[].exitCode'
```

## Repair

### Compare the port mappings of your task definitions match the ports of your target groups and update the task definition
```shell


#!/bin/bash



# Set variables

CLUSTER_NAME=${CLUSTER_NAME}

SERVICE_NAME=${SERVICE_NAME}

TARGET_GROUP_ARN=${TARGET_GROUP_ARN}



# Get task definition for the service

TASK_DEFINITION=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --query 'services[0].taskDefinition' --output text)



# Get the container and port mappings for the task definition

CONTAINER_NAME=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION --query 'taskDefinition.containerDefinitions[0].name' --output text)

CONTAINER_PORT=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION --query 'taskDefinition.containerDefinitions[0].portMappings[0].containerPort' --output text)



# Get the port mapping for the target group

TARGET_GROUP_PORT=$(aws elbv2 describe-target-groups --target-group-arns $TARGET_GROUP_ARN --query 'TargetGroups[0].Port' --output text)



# Compare the container and target group ports and adjust if necessary

if [ "$CONTAINER_PORT" != "$TARGET_GROUP_PORT" ]; then

    echo "Port mappings do not match. Updating task definition..."

    NEW_TASK_DEFINITION=$(aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_DEFINITION --query 'taskDefinition.taskDefinitionArn' --output text)

    echo "Task definition updated to $NEW_TASK_DEFINITION."

else

    echo "Port mappings match. No action required."

fi


```