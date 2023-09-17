module "vpc" {
  source = "../modules/vpc"

  name = "dev-ninja-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]


  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "ninja-dev-bastion"
  description = "dummy security group for testing postgres modules"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name          = "dev-ninja-postgres"
    Service       = "ninjadev"
    ProductDomain = "ninja"
    Environment   = "dev"
    description   = "dummy bastion security group for testing postgres modules"
  }
}


module "redis" {
  source             = "../modules/redis"
  name               = "dev-ninja-redis"
  num_cache_clusters = "2"
  node_type          = "cache.t3.micro"

  engine_version             = "7.0"
  port                       = 6379
  maintenance_window         = "mon:10:40-mon:11:40"
  snapshot_window            = "09:10-10:10"
  snapshot_retention_limit   = 1
  automatic_failover_enabled = false
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false
  apply_immediately          = true
  family                     = "redis7"

  subnet_ids         = module.vpc.public_subnets
  vpc_id             = module.vpc.vpc_id
  source_cidr_blocks = [module.vpc.vpc_cidr_block]
  description        = "dev cache"


  tags = {
    Environment = "dev"
  }
}

data "aws_caller_identity" "current" {}

locals {
  name   = "dev-ninja-postgresql"
  region = "us-east-1"

  tags = {
    Name    = local.name
    Example = local.name
  }
}

################################################################################
# RDS Module
################################################################################

module "db" {
  source = "../modules/rds"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 200

  option_group_name   = "prod-instance-postgresql-14.0"
  publicly_accessible = true

  create_db_option_group = false

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = "ninja_core"
  username = "ninja_admin"
  port     = 5432

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "ninja-monitoring-role-name"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}