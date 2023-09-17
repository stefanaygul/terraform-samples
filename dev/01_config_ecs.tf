data "aws_ssm_parameter" "ninja_db_pass" {
  name = "POSTGRES_NINJA_PASSWORD"
}

data "aws_ssm_parameter" "ninja_db_api_pass" {
  name = "POSTGRES_NINJA_API_PASSWORD"
}

data "aws_ssm_parameter" "ninja_db_admin_pass" {
  name = "POSTGRES_NINJA_ADMIN_PASSWORD"
}

data "aws_ssm_parameter" "ninja_db_url" {
  name = "DEV_DATABASE_URL"
}

data "aws_availability_zones" "available" {}

locals {
  ninja_name = "dev-ninja"

  container_name = "dev-backend"
  container_port = 8081

}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "../modules/ecs_cluster"

  cluster_name = "${local.ninja_name}-cluster"

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  source = "../modules/ecs_service"

  name        = "${local.ninja_name}-service"
  cluster_arn = module.ecs_cluster.arn

  cpu    = 256
  memory = 512

  # Container definition(s)
  container_definitions = {

    (local.container_name) = {
      cpu       = 128
      memory    = 256
      essential = true
      image     = "471223735490.dkr.ecr.us-east-1.amazonaws.com/ninja:4a02f65c89c1b3b5a1f8c5791db0c91b736c856b"
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          "name" : "POSTGRES_NINJA_PASSWORD"
          "value" : data.aws_ssm_parameter.ninja_db_pass.value
        },
        {
          "name" : "POSTGRES_NINJA_API_PASSWORD"
          "value" : data.aws_ssm_parameter.ninja_db_api_pass.value
        },
        {
          "name" : "POSTGRES_NINJA_ADMIN_PASSWORD"
          "value" : data.aws_ssm_parameter.ninja_db_admin_pass.value
        },
        {
          "name" : "DEV_DATABASE_URL"
          "value" : data.aws_ssm_parameter.ninja_db_url.value
        },
        {
          "name" : "POSTGRES_USER"
          "value" : "ninja_admin"
        },
        {
          "name" : "REDIS_POOL_MAX_SIZE"
          "value" : 1000
        },
        {
          "name" : "POSTGRES_DB"
          "value" : "ninja"
        },
        {
          "name" : "POSTGRES_SERVER_PORT"
          "value" : 5432
        },
        {
          "name" : "POSTGRES_NINJA_ADMIN_USER"
          "value" : "ninja_admin"
        },
        {
          "name" : "POSTGRES_NINJA_API_USER"
          "value" : "ninja_api"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      enable_cloudwatch_logging = true

      memory_reservation = 100
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.ecs_map.arn
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = element(module.alb.target_group_arns, 0)
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb_sg.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}

################################################################################
# Supporting Resources
################################################################################

resource "aws_service_discovery_http_namespace" "ecs_map" {
  name        = local.ninja_name
  description = "CloudMap namespace for ${local.ninja_name}"
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.ninja_name}-service"
  description = "Service security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = module.vpc.private_subnets_cidr_blocks

}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${local.ninja_name}-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_sg.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.aws_acm_certificate.amazon_issued.arn
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = "${local.ninja_name}-${local.container_name}"
      backend_protocol = "HTTP"
      backend_port     = local.container_port
      target_type      = "ip"
    },
  ]
}