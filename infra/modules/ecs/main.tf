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
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn = var.task_role_arn


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
    environment = [
      {
        name  = "DYNAMODB_TABLE_NAME"
        value = var.dynamodb_table_name
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = "eu-west-2"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }
])
  
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecsv2-ecs-sg"
  description = "Security group for ECS service"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "service" {
  name            = "ecsv2-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

   load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "ecsv2-container"
    container_port   = 8080
  }
}

