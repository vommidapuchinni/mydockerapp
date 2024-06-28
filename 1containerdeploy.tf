provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# Create an ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"
}

# Define an ECS task definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task-family"
  container_definitions    = <<EOF
[
  {
    "name": "my-container",
    "image": "chinni111/tomcat:3",
    "cpu": 256,
    "memory": 512
  }
]
EOF
}
# Create an ECS service to run tasks
resource "aws_ecs_service" "my_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1
}

