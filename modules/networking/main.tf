#create the primary vpc for workloads
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "cloudnorth-vpc"
    Environment = var.environment
  }
}

# Public subnets — different CIDRs, different AZs
resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_1a
  availability_zone       = var.availability_zone_1a
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-1a"
    Environment = var.environment
  }
}


resource "aws_subnet" "public-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_1b
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-1b"
    Environment = var.environment
  }
}

resource "aws_subnet" "private-app-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_app_subnet_cidr_1a
  availability_zone       = var.availability_zone_1a


  tags = {
    Name        = "private-app-1a"
    Environment = var.environment
  }
}


resource "aws_subnet" "private-app-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_app_subnet_cidr_1b
  availability_zone       = var.availability_zone_1b


  tags = {
    Name        = "private-app-1b"
    Environment = var.environment
  }
}

# Private data subnets
resource "aws_subnet" "private-data-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_data_subnet_cidr_1a
  availability_zone       = var.availability_zone_1a
  

  tags = {
    Name        = "private-data-1a"
    Environment = var.environment
  }
}

resource "aws_subnet" "private-data-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_data_subnet_cidr_1b
  availability_zone       = var.availability_zone_1b


  tags = {
    Name        = "private-data-1b"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "main-igw"
    Environment = var.environment
  }
}

# Public route table — routes to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "main-route-table"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "private-route-table"
    Environment = var.environment
  }
}

# public subnets → public route table
resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-1b" {
  subnet_id      = aws_subnet.public-1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-app-1a" {
  subnet_id      = aws_subnet.private-app-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-app-1b" {
  subnet_id      = aws_subnet.private-app-1b.id
  route_table_id = aws_route_table.private.id
}

# private data subnets → private route table
resource "aws_route_table_association" "private-data-1a" {
  subnet_id      = aws_subnet.private-data-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-data-1b" {
  subnet_id      = aws_subnet.private-data-1b.id
  route_table_id = aws_route_table.private.id
}

# NAT GATEWAY — intentionally omitted  Cost reason: ~$32/month — omitted for portfolio demo
# In production this would be required so ECS tasks in private subnets can pull images from ECR and
# reach AWS services like Secrets Manager






