output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.task_tracker.public_ip
}

output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.logs.bucket
}
