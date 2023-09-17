output "db_instance_automated_backups_replication_id" {
  description = "The automated backups replication id"
  value       = try(aws_db_instance_automated_backups_replication.entr_db_backups, "")
}