output "redis_subnet_group_id" {
  value       = aws_elasticache_subnet_group.this.id
  description = "ElastiCache subnet group id"
}

output "redis_subnet_group_arn" {
  value       = aws_elasticache_subnet_group.this.arn
  description = "ElastiCache subnet group arn"
}

output "redis_parameter_id" {
  value       = aws_elasticache_parameter_group.pg.id
  description = "ElastiCache parameter group id"
}

output "redis_parameter_arn" {
  value       = aws_elasticache_parameter_group.pg.arn
  description = "ElastiCache parameter group arn"
}

output "redis_replicastion_id" {
  value       = aws_elasticache_replication_group.this.id
  description = "ElastiCache(redis) id"
}

output "redis_replicastion_arn" {
  value       = aws_elasticache_replication_group.this.arn
  description = "ElastiCache(redis) arn"
}

output "redis_pimary_endpoint" {
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
  description = "ElastiCache(redis) primary endpoint"
}

output "redis_reader_endpoint" {
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
  description = "ElastiCache(redis) replicas endpoint"
}

output "redis_sg_id" {
  value       = aws_security_group.this.id
  description = "Security Group Id to allow traffic"
}
