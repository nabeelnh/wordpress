variable "project" {
  description = "name of the project"
  type = string
  default = "wordpress"
}

variable "env" {
  description = "Environment of the build"
  type = string
  default = "tst"
}

# -------------------------------------------------------------
# Provider
# -------------------------------------------------------------

variable "region" {
  description = "region of the build"
  default = "eu-west-2"
  type    = string
}

variable "access_key" {
  description = "AWS access key"
  type    = string
}

variable "secret_key" {
  description = "AWS secret key"
  type = string
}

# -------------------------------------------------------------
# Database
# -------------------------------------------------------------

variable "rds_allocated_storage" {
  default = "5"
  type    = string
}

variable "rds_backup_retention_period" {
  default = "7"
  type    = string
}

variable "database_name" {
  description = "Name of the database"
  type = string
  default = "dbname"
}

variable "database_master_username" {
  description = "Username of the database master"
  type = string
  default = "dbmaster"
}

variable "db_instance_type" {
  description = "Instance type to be used by the DB"
  type    = string
  default = "db.t2.micro"
}

# -------------------------------------------------------------
# ASG
# -------------------------------------------------------------

variable "launch-template-ami" {
  type        = string
  description = "Default London Amazon Linux 2 AMI"
  default     = "ami-02f5781cba46a5e8a"
}

variable "asg_desired_capacity" {
  description = "Autoscaling desired capacity"
  type    = string
  default = "1"
}

variable "asg_max_size" {
  description = "Autoscaling maximum capacity"
  default = "3"
  type    = string
}

variable "asg_min_size" {
  description = "Autoscaling minimum capacity"
  default = "1"
  type    = string
}

variable "instance_type" {
  description = "wordpress instance type"
  default = "t2.micro"
  type    = string
}

# -------------------------------------------------------------
# WORDPRESS
# -------------------------------------------------------------

variable "wp_title" {
  default = "Hello Wordpress"
  type    = string
}

variable "wp_user" {
  default = "wpadmin"
  type    = string
}

variable "wp_pass" {
  default = "hellowordpress"
  type    = string
}

variable "wp_email" {
  type = string
}

variable "wp_dbname" {
  default = "wordpress"
  type    = string
}

# -------------------------------------------------------------
# Extra
# -------------------------------------------------------------

variable "workstation-external-cidr" {
  type        = string
  description = "Current location IP address"
  default     = "0.0.0.0/0"
}

