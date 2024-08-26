resource "aws_vpc" "realworld-vpc" {
  cidr_block = "10.10.0.0/25"
}

locals {
  az_public_subnet_map = {
    ap-south-1a = "10.10.0.0/27"
    ap-south-1b = "10.10.0.32/27"
  }
  az_private_subnet_map = {
    ap-south-1a = "10.10.0.64/27"
    ap-south-1b = "10.10.0.96/27"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each                = local.az_public_subnet_map
  vpc_id                  = aws_vpc.realworld-vpc.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true
  tags = {
    "Name"                            = "realworld-public-subnet-${each.key}"
    "kubernetes.io/role/elb"          = "1"
    "kubernetes.io/cluster/realworld" = "owned"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each          = local.az_private_subnet_map
  vpc_id            = aws_vpc.realworld-vpc.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = {
    "Name"                            = "realworld-private-subnet-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/realworld" = "owned"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.realworld-vpc.id
  tags = {
    "Name" = "realworld-igw"
  }
}

resource "aws_eip" "this" {
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.this.id
  subnet_id     = element([for subnet in aws_subnet.public_subnets : subnet.id], 0)
  depends_on = [
    aws_internet_gateway.igw # Ensure that the internet gateway is created before the NAT gateway
  ]
  tags = {
    "Name" = "realworld-nat-gw"
  }
}

resource "aws_route_table" "realworld_public_rt" {
  vpc_id = aws_vpc.realworld-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "realworld-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public_subnets
  route_table_id = aws_route_table.realworld_public_rt.id
  subnet_id      = each.value.id
}


resource "aws_route_table" "realworld_private_rt" {
  vpc_id = aws_vpc.realworld-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    "Name" = "realworld-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private_subnets
  route_table_id = aws_route_table.realworld_private_rt.id
  subnet_id      = each.value.id
}
