resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
}

locals {
  az_subnet_map = {
    ap-south-1a = "10.10.1.0/24"
    ap-south-1b = "10.10.2.0/24"
    ap-south-1c = "10.10.3.0/24"
  }
}

resource "aws_subnet" "main" {
  for_each          = local.az_subnet_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "this" {
  for_each       = aws_subnet.main
  route_table_id = aws_route_table.default.id
  subnet_id      = each.value.id
}
