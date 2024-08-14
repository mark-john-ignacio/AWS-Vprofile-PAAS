variable "aws_access_key" {
  description = "AWS access key"
  type       = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type      = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" 
}