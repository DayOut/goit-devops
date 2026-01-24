output "s3_bucket_name" {
  description = "Назва state S3-бакета"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "DynamoDB Name для блокування стейтів"
  value       = aws_dynamodb_table.terraform_locks.name
}
