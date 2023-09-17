locals {
  defaults = {
    "env"   = "global"
    "owner" = "devops-admins@arielbot.com" # has to be a SPECIFIC HUMAN PERSON, sheesh
    # priority is automatically determined by order of this comma-delimited list
    "rules"                             = "keep_dev_release,keep_dev_latest,keep_dev,keep_prod_release,keep_prod_latest,keep_prod,keep_any"
    "rule.keep_dev_release.tag"         = "dev-release"
    "rule.keep_dev_release.max_images"  = 1
    "rule.keep_dev_latest.tag"          = "dev-latest"
    "rule.keep_dev_latest.max_images"   = 1
    "rule.keep_dev.tag"                 = "dev"
    "rule.keep_dev.max_images"          = 5
    "rule.keep_prod_release.tag"        = "prod-release"
    "rule.keep_prod_release.max_images" = 1
    "rule.keep_prod_latest.tag"         = "prod-latest"
    "rule.keep_prod_latest.max_images"  = 1
    "rule.keep_prod.tag"                = "prod"
    "rule.keep_prod.max_images"         = 5
    "rule.keep_any.max_images"          = 5
  }
  config = merge(local.defaults, var.config)

  rule_list = split(",", local.config["rules"])

  rule_info = zipmap(local.rule_list, range(1, length(local.rule_list) + 1))

  rules = { for rule, priority in local.rule_info :
    (priority) => {
      action = {
        type = "expire"
      }
      description  = "Keep ${local.config["rule.${rule}.max_images"]} ${lookup(local.config, "rule.${rule}.tag", "build")} image(s)"
      rulePriority = priority
      selection = merge(
        {
          countNumber = tonumber(local.config["rule.${rule}.max_images"])
          countType   = "imageCountMoreThan"
          tagStatus   = contains(keys(local.config), "rule.${rule}.tag") ? "tagged" : "any"
        },
        contains(keys(local.config), "rule.${rule}.tag") ? { tagPrefixList = [local.config["rule.${rule}.tag"]] } : {}
      )
    }
  }
  # necessary because the order comes up somewhat random and causes differences in plans
  rules_sorted = [for priority in [for s in sort(formatlist("%03d", keys(local.rules))) : tonumber(s)] :
    local.rules[priority]
  ]

  policy = {
    rules = local.rules_sorted
  }

}

resource "aws_ecr_repository" "managed_repository" {
  name = var.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_lifecycle_policy" "purge_old_images" {
  repository = aws_ecr_repository.managed_repository.name

  policy = jsonencode(local.policy)

}

output "ecr_name" {
  value = aws_ecr_repository.managed_repository.name
}

