resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
  
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
  for_each = {
    for k, v in local.subnets : k => v if v.type == "public"
  }
  
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "priv_asso" {
  for_each = {
    for k, v in local.subnets : k => v if v.type == "private"
  }
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private_rt.id
}

## SG FOR ENDPOINTS

resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [var.ecs_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

## ENDPOINTS

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-2.dynamodb"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb" {  
  for_each = {
    for k, v in local.subnets : k => v if v.type == "private"

  }
  route_table_id = aws_route_table.private_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-2.s3"
  vpc_endpoint_type = "Gateway"
  
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  for_each = {
    for k, v in local.subnets : k => v if v.type == "private"

  }
  route_table_id = aws_route_table.private_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-2.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-2.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}
