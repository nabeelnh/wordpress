# ASG
resource "aws_autoscaling_group" "asg" {
  lifecycle {
    create_before_destroy = true
  }

  name                 = "${var.project}-${var.env}-asg"
  vpc_zone_identifier  = [aws_subnet.web-subnet1.id, aws_subnet.web-subnet2.id, aws_subnet.web-subnet3.id] # AZ to launch ASG
  launch_configuration = "${aws_launch_configuration.launch-configuration.id}"
  default_cooldown     = "60"
  min_size             = "${var.asg_min_size}"
  max_size             = "${var.asg_max_size}"
  desired_capacity     = "${var.asg_desired_capacity}"
  health_check_type    = "ELB"
  metrics_granularity  = "1Minute"

  termination_policies = [
    "OldestInstance",
    "ClosestToNextInstanceHour",
  ]

  target_group_arns = ["${aws_alb_target_group.target-group-default.arn}"]

  tags = [
    {
      key                 = "Project"
      value               = var.project
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.project}-${var.env}-asg"
      propagate_at_launch = true
    },
  ]
}

# Launch Configuration
resource "aws_launch_configuration" "launch-configuration" {
  name_prefix                 = "${var.project}-${var.env}-asg"
  image_id                    = var.launch-template-ami # Can be made into a data source fetching latest image
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.wordpress-instance-profile.name
  security_groups             = ["${aws_security_group.ec2-sg.id}"]
  associate_public_ip_address = false
  user_data                   = templatefile("userdata-asg.sh",
  {
    efs_dns_name                        = aws_efs_file_system.efs.dns_name
    alb_dns_name                        = aws_alb.alb.dns_name
    s3_bucket_static_name               = aws_s3_bucket.s3_bucket_static.id
    DB_NAME                             = aws_ssm_parameter.dbname.value
    DB_USER                             = aws_ssm_parameter.dbuser.value
    DB_PASSWORD                         = aws_ssm_parameter.dbpassword.value
    DB_HOST                             = aws_rds_cluster.default.endpoint
    WP_TITLE                            = var.wp_title
    WP_USER                             = var.wp_user
    WP_PASS                             = var.wp_pass
    WP_EMAIL                            = var.wp_email
})

  lifecycle {
    create_before_destroy = true
  }
}

# Auts Scaling Policy
resource "aws_autoscaling_policy" "asg-policy-scale-up" {
  policy_type               = "StepScaling"
  name                      = "${var.project}-${var.env}-asg-policy-scale-up"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.asg.name}"
  estimated_instance_warmup = "60"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}

resource "aws_autoscaling_policy" "asg-policy-scale-down" {
  policy_type              = "StepScaling"
  name                     = "${var.project}-${var.env}-asg-policy-scale-down"
  adjustment_type          = "PercentChangeInCapacity"
  autoscaling_group_name   = "${aws_autoscaling_group.asg.name}"
  min_adjustment_magnitude = "1"

  step_adjustment {
    scaling_adjustment          = -25
    metric_interval_upper_bound = 0
  }
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "alarm-cpu-high" {
  alarm_name          = "${var.project}-${var.env}-alarm-cpu-high"
  alarm_description   = "${var.project}-${var.env}-alarm-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_actions = ["${aws_autoscaling_policy.asg-policy-scale-up.arn}", "${aws_sns_topic.sns-topic.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "alarm-cpu-low" {
  alarm_name          = "${var.project}-${var.env}-alarm-cpu-low"
  alarm_description   = "${var.project}-${var.env}-alarm-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_actions = ["${aws_autoscaling_policy.asg-policy-scale-down.arn}", "${aws_sns_topic.sns-topic.arn}"]
}

resource "aws_autoscaling_notification" "autoscaling-notification" {
  group_names = [
    "${aws_autoscaling_group.asg.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${aws_sns_topic.sns-topic.arn}"
}

# SNS
resource "aws_sns_topic" "sns-topic" {
  name = "${var.project}-${var.env}-sns"
}

# EC2 Instance Security Group
resource "aws_security_group" "ec2-sg" {
  description = "EC2 Instance Security Group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Project     = var.project
    Environment = var.env
    Name        = "${var.project}-${var.env}-ec2-sg"
  }

  # Allow SSH Traffic from workstation IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.workstation-external-cidr]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow HTTP/HTTPS from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-sg.id}"]
  }
}
