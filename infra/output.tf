# Output variables for endpoints and ports
output "rds_endpoint" {
  value = aws_db_instance.vprofile-rds-mysql.endpoint
}

output "rds_port" {
  value = aws_db_instance.vprofile-rds-mysql.port
}

output "memcached_endpoint" {
  value = aws_elasticache_cluster.vprofile-elasticache-svc.cache_nodes[0].address
}

output "memcached_port" {
  value = aws_elasticache_cluster.vprofile-elasticache-svc.cache_nodes[0].port
}

output "rabbitmq_endpoint" {
  value = aws_mq_broker.vprofile-rmq.instances[0].endpoints[0]
}


# Local file resource to save the endpoints and ports
resource "local_file" "endpoints_file" {
  content  = <<EOF
RDS Endpoint: ${aws_db_instance.vprofile-rds-mysql.endpoint}
RDS Port: ${aws_db_instance.vprofile-rds-mysql.port}
Memcached Endpoint: ${aws_elasticache_cluster.vprofile-elasticache-svc.cache_nodes[0].address}
Memcached Port: ${aws_elasticache_cluster.vprofile-elasticache-svc.cache_nodes[0].port}
RabbitMQ Endpoint: ${aws_mq_broker.vprofile-rmq.instances[0].endpoints[0]}
EOF
  filename = "${path.module}/key/endpoints.txt"
}
