# Configure AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "vscode"
}

# Create VPC
resource "aws_vpc" "custom" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "CustomVPC"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.custom.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.custom.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Route for Internet Gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# # Create Public Subnets
# resource "aws_subnet" "public_subnet_1" {
#   vpc_id                  = aws_vpc.custom.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "us-east-1a"  # Adjust the availability zone accordingly
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "PublicSubnet1"
#   }
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id                  = aws_vpc.custom.id
#   cidr_block              = "10.2.1.0/24"
#   availability_zone       = "us-east-1b"  # Adjust the availability zone accordingly
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "PublicSubnet2"
#   }
# }

# Create Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.custom.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"  # Adjust the availability zone accordingly
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.custom.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"  # Adjust the availability zone accordingly
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom.id
  tags = {
    Name = "CustomIGW"
  }
}

# Create EC2 Instances (you may customize this according to your needs)
resource "aws_instance" "ec2_instance_1" {
  ami           = "ami-0a3c3a20c09d6f377"  # Specify your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = "raiyan"  # Specify your key pair name
  tags = {
    Name = "EC2Instance1"
  }
}

resource "aws_instance" "ec2_instance_2" {
  ami           = "ami-0a3c3a20c09d6f377"  # Specify your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id
  key_name      = "raiyan"  # Specify your key pair name
  tags = {
    Name = "EC2Instance2"
  }
}

# Create Application Load Balancer
resource "aws_lb" "alb" {
  name               = "MyALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false
}

# Create Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.custom.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALBSecurityGroup"
  }
}

# Create RDS Instance
resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "myrds"
  username             = "admin"
  password             = "admin123"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# Create RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

# Create Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.custom.id

  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "RDSSecurityGroup"
  }
}
