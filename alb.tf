# ALB
resource "aws_alb" "alb" {
  name            = "${var.project}-${var.env}-alb"
  subnets         = [aws_subnet.web-subnet1.id, aws_subnet.web-subnet2.id, aws_subnet.web-subnet3.id]
  security_groups = ["${aws_security_group.alb-sg.id}"]

  tags = {
    project     = var.project
    Environment = var.env
    Name        = "${var.project}-${var.env}-alb"
  }
}

# ALB HTTP Listener
resource "aws_alb_listener" "alb-listener-http" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target-group-default.arn
    type             = "forward"
  }
}

# Target Group
resource "aws_alb_target_group" "target-group-default" {
  name     = "${var.project}-${var.env}-tg-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    timeout             = "8"
    interval            = "10"
    unhealthy_threshold = "10"
    healthy_threshold   = "2"
    matcher             = "200-299"
  }

  stickiness {
    type    = "lb_cookie"
    enabled = "false"
  }
}

# ALB Security Group
resource "aws_security_group" "alb-sg" {
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    project     = var.project
    Environment = var.env
    Name        = "${var.project}-${var.env}-alb-sg"
  }

  # Allow HTTP/HTTPS from ALL
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP/HTTPS from ALL
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}
