#------ vpc/main.tf ---

data "aws_availability_zones" "available" {
  exclude_names = ["us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f", ]
}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "aws_capstone_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "aws_capstone_vpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "aws_capstone_public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.aws_capstone_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    "Name" = "aws_capstone_public-${count.index + 1}"
  }
}

resource "aws_subnet" "aws_capstone_private_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.aws_capstone_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    "Name" = "aws_capstone_private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "aws_capstone_internet_gateway" {
  vpc_id = aws_vpc.aws_capstone_vpc.id

  tags = {
    "Name" = "aws_capstone_igw"
  }
}

resource "aws_route_table" "aws_capstone_public_rt" {
  vpc_id = aws_vpc.aws_capstone_vpc.id

  tags = {
    "Name" = "aws_capstone_public"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.aws_capstone_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws_capstone_internet_gateway.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_default_route_table.aws_capstone_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.network_interface_id
}

resource "aws_route_table_association" "aws_capstone_public_association" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.aws_capstone_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.aws_capstone_public_rt.id
}

resource "aws_default_route_table" "aws_capstone_private_rt" {
  default_route_table_id = aws_vpc.aws_capstone_vpc.default_route_table_id

  tags = {
    "Name" = "aws_capstone_private"
  }
}

resource "aws_route_table_association" "aws_capstone_private_association" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.aws_capstone_private_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.aws_capstone_private_rt.id
}

resource "aws_vpc_endpoint" "aws_capstone_vpcendpoint" {
  service_name      = var.service_name
  route_table_ids   = [aws_default_route_table.aws_capstone_private_rt.id]
  vpc_endpoint_type = var.service_type
  vpc_id            = aws_vpc.aws_capstone_vpc.id
}

resource "aws_db_subnet_group" "aws_capstone_rds_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "aws_capstone_rds_subnet_group"
  subnet_ids = aws_subnet.aws_capstone_private_subnet.*.id
  tags = {
    "Name" = "aws_capstone_rds_sng"
  }
}