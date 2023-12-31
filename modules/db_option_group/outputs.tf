output "db_option_group_id" {
  description = "The db option group id"
  value       = try(aws_db_option_group.entr_option_group, "")
}

output "db_option_group_arn" {
  description = "The ARN of the db option group"
  value       = try(aws_db_option_group.entr_option_group, "")
}