
locals {
  security_group_name = "${var.name}-elasticache-redis"
}

resource "aws_elasticache_replication_group" "default" {
  engine               = "redis"
  parameter_group_name = aws_elasticache_parameter_group.default.name
  subnet_group_name    = aws_elasticache_subnet_group.default.name
  security_group_ids   = [aws_security_group.default.id]


  description = var.description

  replication_group_id       = var.name
  num_cache_clusters         = var.num_cache_clusters
  node_type                  = var.node_type
  engine_version             = var.engine_version
  port                       = var.port
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  automatic_failover_enabled = var.automatic_failover_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  apply_immediately          = var.apply_immediately

  # A mapping of tags to assign to the resource.
  tags = merge({ "Name" = var.name }, var.tags)
}

resource "aws_elasticache_parameter_group" "default" {
  name        = var.name
  family      = var.family
  description = var.description
}

resource "aws_elasticache_subnet_group" "default" {
  name        = var.name
  subnet_ids  = var.subnet_ids
  description = var.description
}

##### SECURITY GROUPS #####

resource "aws_security_group" "default" {
  name   = local.security_group_name
  vpc_id = var.vpc_id
  tags   = merge({ "Name" = local.security_group_name }, var.tags)
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr_blocks
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}