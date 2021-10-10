# Bastion Instance - used to configure Wordpress, files to be stored in EFS
# Bastion
resource "aws_instance" "bastion" {
  ami                         = var.launch-template-ami  # Can be made into a data source fetching latest image
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.web-subnet1.id
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.wordpress-instance-profile.name
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  count                       = 1

  # User Data - Bastion Host / Wordpress Config
  user_data                   = templatefile("userdata-bastion.sh",
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


  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }

  tags = {
    Project     = var.project
    Environment = var.env
    Name        = "${var.project}-${var.env}-bastion"
    Role        = "Bastion Host/Provison Wordpress"
    sshUser     = "ec2-user"
  }

  lifecycle {
    ignore_changes = [ami, user_data]
  }

  # Wait for EFS to be provisioned
  depends_on = [aws_efs_file_system.efs,
  aws_efs_mount_target.efs1,
  aws_efs_mount_target.efs2,
  aws_efs_mount_target.efs3,
  aws_rds_cluster.default,
  aws_alb.alb
  ]
}

# Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project}_key_pair"

  # SSH Public Key
  public_key = templatefile("~/.ssh/id_rsa.pub", {})
}

# EC2 Instance Security Group
resource "aws_security_group" "bastion-sg" {
  description = "EC2 Instance Bastion Security Group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Project       = var.project
    Environment   = var.env
    Name          = "${var.project}-${var.env}-bastion-sg"
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

  # Allow all traffic from same Security Group
  #ingress {
  #  from_port = 0
  #  to_port   = 0
  #  protocol  = "-1"
  #  self      = "true"
  #}

  // Allow HTTP/HTTPS from ALB
  #ingress {
  #  from_port       = 80
  #  to_port         = 80
  #  protocol        = "tcp"
  #  security_groups = ["${aws_security_group.alb-sg.id}"]
  #}

  #ingress {
  #  from_port       = 443
  #  to_port         = 443
  #  protocol        = "tcp"
  #  security_groups = ["${aws_security_group.alb-sg.id}"]
  #}
}

# Outputs Bastion 1
output "bastion_private_ip" {
  value = "${aws_instance.bastion[*].private_ip}"
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion[*].public_ip}"
}

output "bastion_id" {
  value = "${aws_instance.bastion[*].id}"
}
