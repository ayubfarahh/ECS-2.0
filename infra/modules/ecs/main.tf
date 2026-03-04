resource "aws_ecs_cluster" "cluster" {
  name = "ecsv2-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
}


# add cloudwatch log group later 
resource "aws_ecs_task_definition" "task" {
  family                   = "ecsv2-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "ecsv2-container"
      image     = var.ecr_image_url
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
  
}

