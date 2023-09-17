output "db_parameter_group_id" {
  description = "The db parameter group id"
  value       = try(aws_db_parameter_group.entr_parameter_group[0].id, "")
}

output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = try(aws_db_parameter_group.entr_parameter_group[0].arn, "")
}