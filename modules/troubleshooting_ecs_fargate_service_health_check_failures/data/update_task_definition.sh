

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