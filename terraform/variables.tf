variable "key_name" {
  description = "Name of the existing AWS EC2 Key Pair to use for SSH"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}
