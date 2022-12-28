resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  enable_dns_support   = lookup(var.vpc_options, "enable_dns_support", true)
  enable_dns_hostnames = lookup(var.vpc_options, "enable_dns_hostnames", true)

  tags = merge(local.default_tags, {
    Name = format("%s-%s-vpc", var.prefix, var.env)
  })
}

resource "aws_subnet" "public" {
  for_each = zipmap(var.azs, var.subnet_cidrs.public)

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(local.default_tags, local.subnet_tags.public, {
    Name = format("%s-%s-public-%s-subnet", var.prefix, var.env, each.key)
  })
}

resource "aws_subnet" "private" {
  for_each = zipmap(var.azs, var.subnet_cidrs.private)

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(local.default_tags, local.subnet_tags.private, {
    Name = format("%s-%s-private-%s-subnet", var.prefix, var.env, each.key)
  })
}

resource "aws_subnet" "database" {
  for_each = zipmap(var.azs, var.subnet_cidrs.database)

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(local.default_tags, local.subnet_tags.database, {
    Name = format("%s-%s-database-%s-subnet", var.prefix, var.env, each.key)
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.default_tags, {
    Name = format("%s-%s-igw", var.prefix, var.env)
  })
}

resource "aws_eip" "this" {
  for_each = var.single_nat_gateway == true ? { "${var.azs[0]}" = true } : { for v in var.azs : v => true }

  vpc = true

  tags = merge(local.default_tags, {
    Name = format("%s-%s-ngw-%s-eip", var.prefix, var.env, each.key)
  })
}

resource "aws_nat_gateway" "this" {
  for_each = var.single_nat_gateway == true ? { "${var.azs[0]}" = true } : { for v in var.azs : v => true }

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s-ngw", var.prefix, var.env, each.key)
  })
}

resource "aws_route_table" "public" {
  for_each = { for v in var.azs : v => true }

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  dynamic "route" {
    for_each = var.public_routes
    content {
      cidr_block                = route.value.cidr_block
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s-%s-public-%s-rtb", var.prefix, var.env, each.key)
  })
}

resource "aws_route_table_association" "public" {
  for_each = { for v in var.azs : v => true }

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route_table" "private" {
  for_each = { for v in var.azs : v => true }

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_private ? [1] : []

    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[var.azs[0]].id : aws_nat_gateway.this[each.key].id
    }
  }

  dynamic "route" {
    for_each = var.private_routes
    content {
      cidr_block                = route.value.cidr_block
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s-%s-private-%s-rtb", var.prefix, var.env, each.key)
  })
}


resource "aws_route_table_association" "private" {
  for_each = { for v in var.azs : v => true }

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "database" {
  for_each = { for v in var.azs : v => true }

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_database ? [1] : []

    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[var.azs[0]].id : aws_nat_gateway.this[each.key].id
    }
  }

  dynamic "route" {
    for_each = var.database_routes
    content {
      cidr_block                = route.value.cidr_block
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s-%s-database-%s-rtb", var.prefix, var.env, each.key)
  })
}

resource "aws_route_table_association" "database" {
  for_each = { for v in var.azs : v => true }

  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[each.key].id
}
