# --> fix error: error creating RDS cluster: InvalidParameterValue: 
#     DatabaseName must begin with a letter and contain only alphanumeric characters.
#     fixed
resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.project}-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.07.1"
  availability_zones      = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  database_name           = aws_ssm_parameter.dbname.value
  master_username         = aws_ssm_parameter.dbuser.value
  master_password         = aws_ssm_parameter.dbpassword.value
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  engine_mode             = "serverless"
  vpc_security_group_ids  = [aws_security_group.db-sg.id]
  skip_final_snapshot     = true
  apply_immediately       = true

  scaling_configuration {
    min_capacity = 1
    max_capacity = 2
  }
}

# Store secure strings in Parameter Store
resource "aws_ssm_parameter" "dbname" {
  name  = "/app/wordpress/DATABASE_NAME"
  type  = "String"
  value = var.database_name
}

resource "aws_ssm_parameter" "dbuser" {
  name  = "/app/wordpress/DATABASE_MASTER_BUSER"
  type  = "String"
  value = var.database_master_username
}

resource "aws_ssm_parameter" "dbpassword" {
  name  = "/app/wordpress/DATABASE_MASTER_PASSWORD"
  type  = "SecureString"
  value = random_password.rds_password.result
}

resource "random_password" "rds_password" {
  length           = 16
  special          = false
  override_special = "_%@/ "
}


# Wordpress RDS subnet group
resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-${var.project}-rds-subnet-group"
  subnet_ids = [aws_subnet.db-subnet1.id, aws_subnet.db-subnet2.id, aws_subnet.db-subnet3.id]

  tags = {
    Project     = var.project
    Environment = var.env
    Name        = "${var.project}-${var.env}-rds-subnet-group"
  }
}

# RDS Security Group
resource "aws_security_group" "db-sg" {
  description = "RDS Security Group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Project     = var.project
    Environment = var.env
    Name        = "${var.project}-${var.env}-db-sg"
  }

  # Allow MySQL from VPC Subnet CIDRs
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Outputs
output "rds_address" {
  value = "${aws_rds_cluster.default.endpoint}"
}

output "rds_username" {
  value = "${aws_rds_cluster.default.master_username}"
  sensitive = true
}
