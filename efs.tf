# EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "${random_id.efs_token.hex}"

  tags = {
    Project       = var.project
    Environment = var.env
    Name        = "${var.project}-${var.env}-efs"
  }
}

resource "aws_efs_mount_target" "efs1" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = aws_subnet.app-subnet1.id
  security_groups = ["${aws_security_group.efs-sg.id}"]
}

resource "aws_efs_mount_target" "efs2" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = aws_subnet.app-subnet2.id
  security_groups = ["${aws_security_group.efs-sg.id}"]
}

resource "aws_efs_mount_target" "efs3" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = aws_subnet.app-subnet3.id
  security_groups = ["${aws_security_group.efs-sg.id}"]
}

resource "random_id" "efs_token" {
  byte_length = 8
  prefix      = "${var.project}-${var.env}"
}

# EFS Security Group
resource "aws_security_group" "efs-sg" {
  description = "EFS Security Group"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags = {
    Project       = var.project
    Environment = var.env
    Name        = "${var.project}-${var.env}-efs-sg"
  }

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.vpc.cidr_block}",
    ]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.vpc.cidr_block}",
    ]
  }
}

// Outputs
output "efs_id" {
  value = "${aws_efs_file_system.efs.id}"
}

output "efs_dns_name" {
  value = "${aws_efs_file_system.efs.dns_name}"
}
