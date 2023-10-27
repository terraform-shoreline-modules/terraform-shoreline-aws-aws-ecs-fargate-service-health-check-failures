aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ID} --query 'tasks[].containers[].name'

aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ID} --query 'tasks[].containers[].lastStatus'

aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ID} --query 'tasks[].containers[].exitCode'