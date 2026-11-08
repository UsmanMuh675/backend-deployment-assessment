
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


# ==========================================
# AMAZON LINUX 2023 AMI
# ==========================================

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


# ==========================================
# 1. VPC
# ==========================================

resource "aws_vpc" "startuptech_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "startuptech-vpc"
    Environment = "assessment"
  }
}

# ==========================================
# 2. PUBLIC SUBNETS
# ==========================================

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.startuptech_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "startuptech-public-subnet-1"
    Type = "public"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.startuptech_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "startuptech-public-subnet-2"
    Type = "public"
  }
}

# ==========================================
# 3. PRIVATE SUBNETS
# ==========================================

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.startuptech_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zone_1

  tags = {
    Name = "startuptech-private-subnet-1"
    Type = "private"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.startuptech_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zone_2

  tags = {
    Name = "startuptech-private-subnet-2"
    Type = "private"
  }
}

# ==========================================
# 4. INTERNET GATEWAY
# ==========================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.startuptech_vpc.id

  tags = {
    Name = "startuptech-igw"
  }
}

# ==========================================
# 5. PUBLIC ROUTE TABLE
# ==========================================

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.startuptech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "startuptech-public-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# ==========================================
# 6. NAT GATEWAY
# ==========================================

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "startuptech-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "startuptech-nat-gateway"
  }
}

# ==========================================
# 7. PRIVATE ROUTE TABLE
# ==========================================

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.startuptech_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "startuptech-private-rt"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

# ==========================================
# 8. ALB SECURITY GROUP
# ==========================================

resource "aws_security_group" "alb_sg" {
  name        = "startuptech-alb-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "startuptech-alb-sg"
  }
}

# ==========================================
# 9. BASTION SECURITY GROUP
# ==========================================

resource "aws_security_group" "bastion_sg" {
  name        = "startuptech-bastion-sg"
  description = "Allow SSH from administrator IP"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "startuptech-bastion-sg"
  }
}

# ==========================================
# 10. BACKEND SECURITY GROUP
# ==========================================

resource "aws_security_group" "backend_sg" {
  name        = "startuptech-backend-sg"
  description = "Allow traffic from ALB and Bastion"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    description     = "Backend API from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "startuptech-backend-sg"
  }
}

# ==========================================
# 11. MONGODB SECURITY GROUP
# ==========================================

resource "aws_security_group" "mongodb_sg" {
  name        = "startuptech-mongodb-sg"
  description = "Allow MongoDB from Backend only"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    description     = "MongoDB from Backend"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  ingress {
  description     = "SSH from Bastion"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  security_groups = [aws_security_group.bastion_sg.id]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "startuptech-mongodb-sg"
  }
}


# ==========================================
# 12. BACKEND EC2 INSTANCE
# ==========================================

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = "startuptech-bastion-key"
  
  associate_public_ip_address = false

  user_data = file("${path.module}/user_data/backend_setup.sh")

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "startuptech-backend"
    Environment = "assessment"
    Role        = "backend"
  }
}

# ==========================================
# 13. MONGODB EC2 INSTANCE
# ==========================================

resource "aws_instance" "mongodb" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_2.id
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  key_name               = "startuptech-bastion-key"

  associate_public_ip_address = false

  user_data = file("${path.module}/user_data/mongodb_setup.sh")

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "startuptech-mongodb"
    Environment = "assessment"
    Role        = "database"
  }
}
