data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "CodeDeployRole" {
  name               = "CodeDeploy-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.CodeDeployRole.name
}

resource "aws_iam_role_policy_attachment" "ECSCodeDeploy" {
    policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
    role       = aws_iam_role.CodeDeployRole.name
}

resource "aws_codedeploy_deployment_config" "ECS_12hr_canary" {
  deployment_config_name = "ECS10Percent12Hour"
  compute_platform = "ECS"
  traffic_routing_config {
    type = "TimeBasedCanary"
    time_based_canary {
      interval = 720 #12 hours
      percentage = 10
    }
  }
}

resource "aws_codedeploy_app" "aline" {
  compute_platform = "ECS"
  name             = "aline"
}

resource "aws_codedeploy_deployment_group" "accounts" {
  app_name               = aws_codedeploy_app.aline.name
  deployment_config_name = aws_codedeploy_deployment_config.ECS_12hr_canary.deployment_config_name
  deployment_group_name  = "accounts"
  service_role_arn       = aws_iam_role.CodeDeployRole.arn

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
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs.name
    service_name = aws_ecs_service.accounts.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.accounts.arn]
      }

      target_group {
        name = aws_lb_target_group.accounts_blue.name
      }

      target_group {
        name = aws_lb_target_group.accounts_green.name
      }
    }
  }
}

resource "aws_codedeploy_deployment_group" "banks" {
  app_name               = aws_codedeploy_app.aline.name
  deployment_config_name = aws_codedeploy_deployment_config.ECS_12hr_canary.deployment_config_name
  deployment_group_name  = "banks"
  service_role_arn       = aws_iam_role.CodeDeployRole.arn

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
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs.name
    service_name = aws_ecs_service.banks.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.banks.arn]
      }

      target_group {
        name = aws_lb_target_group.banks_blue.name
      }

      target_group {
        name = aws_lb_target_group.banks_green.name
      }
    }
  }
}

resource "aws_codedeploy_deployment_group" "cards" {
  app_name               = aws_codedeploy_app.aline.name
  deployment_config_name = aws_codedeploy_deployment_config.ECS_12hr_canary.deployment_config_name
  deployment_group_name  = "cards"
  service_role_arn       = aws_iam_role.CodeDeployRole.arn

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
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs.name
    service_name = aws_ecs_service.cards.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.cards.arn]
      }

      target_group {
        name = aws_lb_target_group.cards_blue.name
      }

      target_group {
        name = aws_lb_target_group.cards_green.name
      }
    }
  }
}

resource "aws_codedeploy_deployment_group" "transactions" {
  app_name               = aws_codedeploy_app.aline.name
  deployment_config_name = aws_codedeploy_deployment_config.ECS_12hr_canary.deployment_config_name
  deployment_group_name  = "transactions"
  service_role_arn       = aws_iam_role.CodeDeployRole.arn

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
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs.name
    service_name = aws_ecs_service.transactions.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.transactions.arn]
      }

      target_group {
        name = aws_lb_target_group.transactions_blue.name
      }

      target_group {
        name = aws_lb_target_group.transactions_green.name
      }
    }
  }
}

resource "aws_codedeploy_deployment_group" "underwriter" {
  app_name               = aws_codedeploy_app.aline.name
  deployment_config_name = aws_codedeploy_deployment_config.ECS_12hr_canary.deployment_config_name
  deployment_group_name  = "underwriter"
  service_role_arn       = aws_iam_role.CodeDeployRole.arn

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
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs.name
    service_name = aws_ecs_service.underwriter.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.underwriter.arn]
      }

      target_group {
        name = aws_lb_target_group.underwriter_blue.name
      }

      target_group {
        name = aws_lb_target_group.underwriter_green.name
      }
    }
  }
}

resource "aws_codedeploy_deployment_group" "users" {
  app_name               = aws_codedeploy_app.aline.name
  deployment_config_name = aws_codedeploy_deployment_config.ECS_12hr_canary.deployment_config_name
  deployment_group_name  = "users"
  service_role_arn       = aws_iam_role.CodeDeployRole.arn

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
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs.name
    service_name = aws_ecs_service.users.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.users.arn]
      }

      target_group {
        name = aws_lb_target_group.users_blue.name
      }

      target_group {
        name = aws_lb_target_group.users_green.name
      }
    }
  }
}