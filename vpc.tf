# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "Main VPC"
  }
}

# Reserved Subnets - Buffer for expansion
resource "aws_subnet" "reserved-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.16.0.0/20"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-reserved-A"
  }
}

resource "aws_subnet" "reserved-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.16.64.0/20"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "sn-reserved-B"
  }
}


resource "aws_subnet" "reserved-subnet3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.16.128.0/20"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "sn-reserved-C"
  }
}

# Database subnet
resource "aws_subnet" "db-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.16.16.0/20"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "sn-db-A"
  }
}

resource "aws_subnet" "db-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.16.80.0/20"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "sn-db-B"
  }
}

resource "aws_subnet" "db-subnet3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.16.144.0/20"
  availability_zone = "eu-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "sn-db-C"
  }
}

# Application subnet
resource "aws_subnet" "app-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.16.32.0/20"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "sn-app-A"
  }
}

resource "aws_subnet" "app-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.16.96.0/20"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "sn-app-B"
  }
}

resource "aws_subnet" "app-subnet3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.16.160.0/20"
  availability_zone = "eu-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "sn-app-C"
  }
}



# Web subnet
resource "aws_subnet" "web-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.16.48.0/20"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-web-A"
  }
}

resource "aws_subnet" "web-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.16.112.0/20"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-web-B"
  }
}

resource "aws_subnet" "web-subnet3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.16.176.0/20"
  availability_zone = "eu-west-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-web-C"
  }
}