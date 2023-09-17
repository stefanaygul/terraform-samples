variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "bucket_acl" {
  description = "The canned ACL to apply to the S3 bucket."
  type        = string
  default     = "private"
}

variable "bucket_tags" {
  description = "A map of tags to apply to the S3 bucket."
  type        = map(string)
  default     = {}
}