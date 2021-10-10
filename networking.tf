# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet-Gateway"
  }
}

# Create Web layer route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "rt-a" {
  subnet_id      = aws_subnet.web-subnet1.id
  route_table_id = aws_route_table.web-rt.id
}

resource "aws_route_table_association" "rt-b" {
  subnet_id      = aws_subnet.web-subnet2.id
  route_table_id = aws_route_table.web-rt.id
}

resource "aws_route_table_association" "rt-c" {
  subnet_id      = aws_subnet.web-subnet3.id
  route_table_id = aws_route_table.web-rt.id
}