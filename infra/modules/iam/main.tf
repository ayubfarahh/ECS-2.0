data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = "${aws_iam_role.ecs_tasks_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


data "aws_iam_policy_document" "task_role_dynamodb" {
  statement { 
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:eu-west-2:940622738555:table/${var.dynamodb_table_name}"
    ]
  
    }
}

resource "aws_iam_role" "task_role" {
  name               = "task-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
}

resource "aws_iam_policy" "task_role_policy" {
  name   = "task-role-policy"
  policy = "${data.aws_iam_policy_document.task_role_dynamodb.json}"
  
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  policy_arn = "${aws_iam_policy.task_role_policy.arn}"
  role      = ["${aws_iam_role.task_role.name}"]
  
}