resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name            = "VPC for receipt-archive"
    receipt-archive = 1
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name            = "Internet Gateway for receipt-archive"
    receipt-archive = 1
  }
}

resource "aws_subnet" "public_subnet_az_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = var.availability_zone_a

  tags = {
    Name            = "Public Subnet"
    receipt-archive = 1
  }
}

resource "aws_subnet" "public_subnet_az_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = var.availability_zone_b

  tags = {
    Name            = "Public Subnet"
    receipt-archive = 1
  }
}

resource "aws_subnet" "public_subnet_az_c" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = var.availability_zone_c

  tags = {
    Name            = "Public Subnet"
    receipt-archive = 1
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name            = "VPC Route Table"
    receipt-archive = 1
  }
}

resource "aws_main_route_table_association" "main_route_table_association" {
  vpc_id         = aws_vpc.main_vpc.id
  route_table_id = aws_route_table.main_route_table.id
}

//resource "aws_subnet" "private_subnet_az_a" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.208.0/20"
//  availability_zone = var.availability_zone_a
//
//  tags = {
//    Name = "Private Subnet"
//    receipt-archive = 1
//  }
//}
//
//resource "aws_subnet" "private_subnet_az_b" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.224.0/20"
//  availability_zone = var.availability_zone_b
//
//  tags = {
//    Name = "Private Subnet"
//    receipt-archive = 1
//  }
//}
//
//resource "aws_subnet" "private_subnet_az_c" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.240.0/20"
//  availability_zone = var.availability_zone_c
//
//  tags = {
//    Name = "Private Subnet"
//    receipt-archive = 1
//  }
//}
//
//resource "aws_route_table_association" "my_vpc_us_east_1a_public" {
//  subnet_id = aws_subnet.public_subnet_az_a.id
//  route_table_id = aws_route_table.main.id
//}
//
//resource "aws_route_table_association" "my_vpc_us_east_1b_public" {
//  subnet_id = aws_subnet.public_subnet_az_b.id
//  route_table_id = aws_route_table.main.id
//}
//
//resource "aws_route_table_association" "my_vpc_us_east_1c_public" {
//  subnet_id = aws_subnet.public_subnet_az_c.id
//  route_table_id = aws_route_table.main.id
//}
