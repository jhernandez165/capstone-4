resource "aws_lb" "default" {
  name               = "${var.project}-cluster-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = aws_subnet.public.*.id
}

resource "aws_lb_target_group" "accounts_blue" {
  name        = "accounts-blue-target-group"
  port        = 8070
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group" "accounts_green" {
  name        = "accounts-green-target-group"
  port        = 8070
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "accounts" {
  load_balancer_arn = aws_lb.default.id
  port              = "8070"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.accounts_blue.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "banks_blue" {
  name        = "banks-blue-target-group"
  port        = 8071
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group" "banks_green" {
  name        = "banks-green-target-group"
  port        = 8071
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "banks" {
  load_balancer_arn = aws_lb.default.id
  port              = "8071"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.banks_blue.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "cards_blue" {
  name        = "cards-blue-target-group"
  port        = 8072
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group" "cards_green" {
  name        = "cards-green-target-group"
  port        = 8072
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "cards" {
  load_balancer_arn = aws_lb.default.id
  port              = "8072"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cards_blue.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "transactions_blue" {
  name        = "transactions-blue-target-group"
  port        = 8073
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group" "transactions_green" {
  name        = "transactions-green-target-group"
  port        = 8073
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "transactions" {
  load_balancer_arn = aws_lb.default.id
  port              = "8073"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.transactions_blue.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "underwriter_blue" {
  name        = "underwriter-blue-target-group"
  port        = 8074
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group" "underwriter_green" {
  name        = "underwriter-green-target-group"
  port        = 8074
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "underwriter" {
  load_balancer_arn = aws_lb.default.id
  port              = "8074"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.underwriter_blue.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "users_blue" {
  name        = "users-blue-target-group"
  port        = 8075
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group" "users_green" {
  name        = "users-green-target-group"
  port        = 8075
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    interval = 60
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "users" {
  load_balancer_arn = aws_lb.default.id
  port              = "8075"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.users_blue.id
    type             = "forward"
  }
}