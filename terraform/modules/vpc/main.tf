resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.base_label}-${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.base_label}-${var.name}-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.base_label}-${var.name}-public-subnet-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.base_label}-${var.name}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public_subnet)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + length(var.availability_zones))
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.base_label}-${var.name}-private-subnet-${count.index}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.base_label}-${var.name}-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}
