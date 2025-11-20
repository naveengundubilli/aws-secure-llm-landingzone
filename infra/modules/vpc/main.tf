data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

resource "aws_subnet" "private_app" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, each.key)
  availability_zone       = each.value
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-priv-app-${each.value}"
    Tier = "app"
  })
}

resource "aws_subnet" "private_shared" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, each.key + 4)
  availability_zone       = each.value
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-priv-shared-${each.value}"
    Tier = "shared"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-igw" })
}

resource "aws_eip" "nat" {
  vpc = true
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private_shared["0"].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-gw"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-rt-private"
  })
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private_app" {
  for_each       = aws_subnet.private_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_network_acl" "strict" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nacl-strict"
  })
}

resource "aws_network_acl_rule" "ingress_ephemeral" {
  network_acl_id = aws_network_acl.strict.id
  rule_number    = 100
  egress         = false
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_subnet_network_acl_association" "private_app" {
  for_each       = aws_subnet.private_app
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.strict.id
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "App SG for internal services"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "From within VPC only"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-sg"
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private.id]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpce-s3"
  })
}

data "aws_region" "current" {}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private_app : s.id]
}

output "app_sg_id" {
  value = aws_security_group.app.id
}
