variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "aws_access_key" {
  type      = string
  sensitive = true
  default   = ""
}
variable "aws_secret_access_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "domain_name" {
  type        = string
  description = "The domain name to use"
  default     = "example.com"
}

variable "bucket_prefix" {
  type        = string
  description = "The prefix for the S3 bucket"
  default     = "ninja-cloudfront"
}