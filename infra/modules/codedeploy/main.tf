resource "aws_codedeploy_app" "main" {
    compute_platform = "ECS"
    name = "url-shortener-code_deploy"
  
}

resource "aws_codedeploy_deployment_group" "deployment-group" {
    app_name = aws_codedeploy_app.main.name
    deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
    deployment_group_name = "url-shortener-deployment-group"
    service_role_arn = var.code_deploy_role_arn

    auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

    blue_green_deployment_config {
        deployment_ready_option {
        action_on_timeout = "CONTINUE_DEPLOYMENT"
        }

        terminate_blue_instances_on_deployment_success {
        action                           = "TERMINATE"
        termination_wait_time_in_minutes = 3
        }
    }

    deployment_style {
        deployment_option = "WITH_TRAFFIC_CONTROL"
        deployment_type   = "BLUE_GREEN"
    }

    ecs_service {
        cluster_name = var.ecs_cluster_name
        service_name = var.ecs_service_name
    }
    
    load_balancer_info {
      target_group_pair_info {
        prod_traffic_route {
          listener_arns = [var.https_listener_arn]
        }

        test_traffic_route {
          listener_arns = [ var.test_listener_arn ]
        }

        target_group {
          name = var.target_group_arn
        }

        target_group {
          name = var.green_target_group_arn
        }
      }
    }
}