provider "aws" {
  # Configuration options
  region = "us-east-1"
}

# Create EC2
resource "aws_instance" "Double-Server" {
  ami = "ami-0a3c3a20c09d6f377"
  key_name = "key_name"
  instance_type = "t2.micro"
}

# Create VPC
resource "aws_vpc" "double-vpc" {
  cidr_block = "10.10.0.0/16"
}

# Create Subnet
resource "aws_subnet" "double-subnet" {
  vpc_id     = aws_vpc.double-vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "double-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "double-igw" {
  vpc_id = aws_vpc.double-vpc.id

  tags = {
    Name = "double-igw"
  }
}

# Create Route Table
resource "aws_route_table" "double-rt" {
  vpc_id = aws_vpc.double-vpc.id

  route {
    # Where traffic is accepted
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.double-igw.id
  }

  tags = {
    Name = "double rt"
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "double-rt-association" {
  subnet_id      = aws_subnet.double-subnet.id
  route_table_id = aws_route_table.double-rt.id
}

# Create Security Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

# Inbound Rules
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.main.ipv6_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Outbound Rules
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
