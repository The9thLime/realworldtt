resource "aws_vpc" "realworld-vpc" {
  cidr_block = "10.10.0.0/25"
}

locals {
  az_subnet_map = {
    ap-south-1a = "10.10.0.0/27"
    ap-south-1b = "10.10.0.32/27"
  }
}

resource "aws_subnet" "subnets" {
  for_each          = local.az_subnet_map
  vpc_id            = aws_vpc.realworld-vpc.id
  availability_zone = each.key
  cidr_block        = each.value
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.realworld-vpc.id
}

resource "aws_route_table" "realworld-rt" {
  vpc_id = aws_vpc.realworld-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "this" {
  for_each       = aws_subnet.subnets
  route_table_id = aws_route_table.realworld-rt.id
  subnet_id      = each.value.id
}
