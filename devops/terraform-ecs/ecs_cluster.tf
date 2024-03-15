
  # ECS Cluster
resource "aws_ecs_cluster" "ecs" {
  name     = "${var.project}-cluster"
}

resource "aws_iam_role" "task_execution" {
  name = "${var.project}-Task-Execution-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "log_policy" {
  name        = "ECS-logs-policy"
  path        = "/"
  description = "ECS logs policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution_SecretsPolicy" {
  policy_arn = aws_iam_policy.secret_policy.arn
  role       = aws_iam_role.task_execution.name
}

resource "aws_iam_role_policy_attachment" "task_execution_LogPolicy" {
  policy_arn = aws_iam_policy.log_policy.arn
  role       = aws_iam_role.task_execution.name
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role        = aws_iam_role.task_execution.name
}

resource "aws_ecs_task_definition" "accounts" {
  family                   = "accounts"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution.arn 
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:host::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:dbname::"
        },
        {
          name      = "ENCRYPT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:encrypt_key::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:jwt_key::"
        }
      ]
      environment = [
        {
            name  = "DB_PORT",
            value = "${tostring(aws_db_instance.default.port)}"
        },
        {
            name  = "APP_PORT",
            value = "8070"
        }
            ]
      essential = true
      image     = "239153380322.dkr.ecr.us-west-1.amazonaws.com/cm-account-microservice:latest"
      name      = "accounts"
      cpu       = 256
      memory    = 512
      portMappings = [
          {
              containerPort = 8070
              hostPort = 8070
          }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
                    awslogs-group = "accounts-container",
                    awslogs-region = var.region,
                    awslogs-create-group = "true",
                    awslogs-stream-prefix = "accounts"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "accounts" {
  name            = "accounts"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.accounts.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.accounts_blue.arn
    container_name   = "accounts"
    container_port   = 8070
  }
  network_configuration {                                                                                                         
    subnets         = aws_subnet.private.*.id
    security_groups  = [aws_security_group.tasks_sg.id]
  }
}

resource "aws_ecs_task_definition" "banks" {
  family                   = "banks"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution.arn 
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:host::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:dbname::"
        },
        {
          name      = "ENCRYPT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:encrypt_key::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:jwt_key::"
        }
      ]
      environment = [
        {
            name  = "DB_PORT",
            value = "${tostring(aws_db_instance.default.port)}"
        },
        {
            name  = "APP_PORT",
            value = "8071"
        }
            ]
      essential = true
      image     = "239153380322.dkr.ecr.us-west-1.amazonaws.com/cm-bank-microservice:latest"
      name      = "banks"
      cpu       = 256
      memory    = 512
      portMappings = [
          {
              containerPort = 8071
              hostPort = 8071
          }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
                    awslogs-group = "banks-container",
                    awslogs-region = var.region,
                    awslogs-create-group = "true",
                    awslogs-stream-prefix = "banks"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "banks" {
  name            = "banks"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.banks.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.banks_blue.arn
    container_name   = "banks"
    container_port   = 8071
  }
  network_configuration {                                                                                                         
    subnets         = aws_subnet.private.*.id
    security_groups  = [aws_security_group.tasks_sg.id]
  }
}

resource "aws_ecs_task_definition" "cards" {
  family                   = "cards"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution.arn 
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:host::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:dbname::"
        },
        {
          name      = "ENCRYPT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:encrypt_key::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:jwt_key::"
        }
      ]
      environment = [
        {
            name  = "DB_PORT",
            value = "${tostring(aws_db_instance.default.port)}"
        },
        {
            name  = "APP_PORT",
            value = "8072"
        }
            ]
      essential = true
      image     = "239153380322.dkr.ecr.us-west-1.amazonaws.com/cm-card-microservice:latest"
      name      = "cards"
      cpu       = 256
      memory    = 512
      portMappings = [
          {
              containerPort = 8072
              hostPort = 8072
          }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
                    awslogs-group = "cards-container",
                    awslogs-region = var.region,
                    awslogs-create-group = "true",
                    awslogs-stream-prefix = "cards"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "cards" {
  name            = "cards"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.cards.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.cards_blue.arn
    container_name   = "cards"
    container_port   = 8072
  }
  network_configuration {                                                                                                         
    subnets         = aws_subnet.private.*.id
    security_groups  = [aws_security_group.tasks_sg.id]
  }
}

resource "aws_ecs_task_definition" "transactions" {
  family                   = "transactions"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution.arn 
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:host::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:dbname::"
        },
        {
          name      = "ENCRYPT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:encrypt_key::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:jwt_key::"
        }
      ]
      environment = [
        {
            name  = "DB_PORT",
            value = "${tostring(aws_db_instance.default.port)}"
        },
        {
            name  = "APP_PORT",
            value = "8073"
        }
            ]
      essential = true
      image     = "239153380322.dkr.ecr.us-west-1.amazonaws.com/cm-transaction-microservice:latest"
      name      = "transactions"
      cpu       = 256
      memory    = 512
      portMappings = [
          {
              containerPort = 8073
              hostPort = 8073
          }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
                    awslogs-group = "transactions-container",
                    awslogs-region = var.region,
                    awslogs-create-group = "true",
                    awslogs-stream-prefix = "transactions"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "transactions" {
  name            = "transactions"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.transactions.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.transactions_blue.arn
    container_name   = "transactions"
    container_port   = 8073
  }
  network_configuration {                                                                                                         
    subnets         = aws_subnet.private.*.id
    security_groups  = [aws_security_group.tasks_sg.id]
  }
}

resource "aws_ecs_task_definition" "underwriter" {
  family                   = "underwriter"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution.arn 
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:host::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:dbname::"
        },
        {
          name      = "ENCRYPT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:encrypt_key::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:jwt_key::"
        }
      ]
      environment = [
        {
            name  = "DB_PORT",
            value = "${tostring(aws_db_instance.default.port)}"
        },
        {
            name  = "APP_PORT",
            value = "8074"
        }
            ]
      essential = true
      image     = "239153380322.dkr.ecr.us-west-1.amazonaws.com/cm-underwriter-microservice:latest"
      name      = "underwriter"
      cpu       = 256
      memory    = 512
      portMappings = [
          {
              containerPort = 8074
              hostPort = 8074
          }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
                    awslogs-group = "underwriter-container",
                    awslogs-region = var.region,
                    awslogs-create-group = "true",
                    awslogs-stream-prefix = "underwriter"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "underwriter" {
  name            = "underwriter"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.underwriter.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.underwriter_blue.arn
    container_name   = "underwriter"
    container_port   = 8074
  }
  network_configuration {                                                                                                         
    subnets         = aws_subnet.private.*.id
    security_groups  = [aws_security_group.tasks_sg.id]
  }
}

resource "aws_ecs_task_definition" "users" {
  family                   = "users"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution.arn 
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:host::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:dbname::"
        },
        {
          name      = "ENCRYPT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:encrypt_key::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.aline_secret.arn}:jwt_key::"
        }
      ]
      environment = [
        {
            name  = "DB_PORT",
            value = "${tostring(aws_db_instance.default.port)}"
        },
        {
            name  = "APP_PORT",
            value = "8075"
        }
            ]
      essential = true
      image     = "239153380322.dkr.ecr.us-west-1.amazonaws.com/cm-user-microservice:latest"
      name      = "users"
      cpu       = 256
      memory    = 512
      portMappings = [
          {
              containerPort = 8075
              hostPort = 8075
          }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
                    awslogs-group = "users-container",
                    awslogs-region = var.region,
                    awslogs-create-group = "true",
                    awslogs-stream-prefix = "users"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "users" {
  name            = "users"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.users.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.users_blue.arn
    container_name   = "users"
    container_port   = 8075
  }
  network_configuration {                                                                                                         
    subnets         = aws_subnet.private.*.id
    security_groups  = [aws_security_group.tasks_sg.id]
  }
}