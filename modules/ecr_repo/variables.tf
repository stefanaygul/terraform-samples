variable "name" {
  description = "The name of the ECR repo"
}

variable "config" {
  description = "Configuration overrides if necessary."
  type        = map(string)
  default     = {}
}