## CODEDEPLOY PERMS
data "aws_iam_policy_document" "code_deploy_policy_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
  
}

resource "aws_iam_role" "code_deploy_role" {
  name               = "code-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.code_deploy_policy_role.json  
}

resource "aws_iam_role_policy_attachment" "code_deploy_policy_role_attachment" {
  role       = aws_iam_role.code_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

## ECS PERMS
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
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
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

  statement {
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:940622738555:repository/ecsv2"
    ]
  }
}

resource "aws_iam_role" "task_role" {
  name               = "task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_policy" "task_role_policy" {
  name   = "task-role-policy"
  policy = data.aws_iam_policy_document.task_role_dynamodb.json
  
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  policy_arn = aws_iam_policy.task_role_policy.arn
  role      = aws_iam_role.task_role.name
  
}

## OIDC for github actions

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [ "sts.amazonaws.com" ]
  thumbprint_list = [ "6938fd4d98bab03faadb97b34396831e3780aea1" ]

}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ayubfarahh/ECS-2.0:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = "github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

## perm for github actions to use ECR and do stuff

data "aws_iam_policy_document" "github_actions_ecr" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
       "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:940622738555:repository/ecsv2"
    ]
  }
}

resource "aws_iam_policy" "github_actions_ecr" {
  name   = "github-actions-ecr-policy"
  policy = data.aws_iam_policy_document.github_actions_ecr.json
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}