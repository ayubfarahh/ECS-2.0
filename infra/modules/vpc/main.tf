resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
  
}

resource "aws_subnet" "public" {
  for_each = {
    for k, v in local.subnets : k => v 
    if v.type == "public" 
  }
  
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true 

}


resource "aws_subnet" "private" {
  for_each = {
    for k, v in local.subnets : k => v
    if v.type == "private"
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  
}

resource "aws_route_table_association" "pub_asso" {
  subnet_id      = aws_subnet.public
  route_table_id = aws_route_table.public_rt
}

resource "aws_route_table_association" "priv_asso" {
  subnet_id      = aws_subnet.private
  route_table_id = aws_route_table.private_rt.id
}

