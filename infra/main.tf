resource "tls_private_key" "vprofile-bean-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "vprofile-bean-key" {
  key_name   = "vprofile-bean-key"
  public_key = tls_private_key.vprofile-bean-key.public_key_openssh
}

resource "local_file" "private-key" {
  content  = tls_private_key.vprofile-bean-key.private_key_pem
  filename = "${path.module}/key/vprofile-bean-key.pem"
}

resource "aws_security_group" "vprofile-backend-SG" {
  name = "vprofile-backend-SG"
  description = "Security group for vprofile backend"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }
}

resource "aws_db_subnet_group" "vprofile-rds-sub-grp" {
  name      = "vprofile-rds-sub-grp"
  description = "vprofile RDS subnet group"
  subnet_ids = data.aws_subnets.all.ids
  
}

resource "aws_db_parameter_group" "vprofile-para-grp" {
  name       = "vprofile-para-grp"
  family     = "mysql8.0"
  description = "Parameter group for vprofile MySQL 8.0"

  parameter {
    name = "max_connections"
    value = "1000"
  }

  parameter {
    name = "innodb_buffer_pool_size"
    value = "134217728"
  }
  
}

resource "aws_db_instance" "vprofile-rds-mysql" {
  identifier              = "vprofile-rds-mysql"
  engine                  = "mysql"
  engine_version          = "8.0.32"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_subnet_group_name    = aws_db_subnet_group.vprofile-rds-sub-grp.name
  vpc_security_group_ids  = [aws_security_group.vprofile-backend-SG.id]
  publicly_accessible     = false
  auto_minor_version_upgrade = true
  backup_retention_period = 7
  monitoring_interval     = 60
  monitoring_role_arn     = aws_iam_role.rds_monitoring.arn
  parameter_group_name    = aws_db_parameter_group.vprofile-para-grp.name
  apply_immediately       = true
  skip_final_snapshot     = true

  db_name                    = "accounts"
  username                = "admin"
  password                = random_password.rds_password.result

  tags = {
    Name = "vprofile-rds-mysql"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_iam_role_policy_attachment.rds_monitoring]
}

resource "random_password" "rds_password" {
  length  = 16
  special = true
}

resource "local_file" "rds_password_file" {
  content  = random_password.rds_password.result
  filename = "${path.module}/key/rds_password.txt"
}

resource "aws_iam_role" "rds_monitoring" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_elasticache_subnet_group" "vprofile-memcached-sub-group" {
  name       = "vprofile-memcached-sub-group"
  description = "Subnet group for vprofile memcached"
  subnet_ids = data.aws_subnets.all.ids
}

resource "aws_elasticache_parameter_group" "vprofile-memcached-para-grp" {
  name   = "vprofile-memcached-para-grp"
  family = "memcached1.6"
}

resource "aws_elasticache_cluster" "vprofile-elasticache-svc" {
  cluster_id           = "vprofile-elasticache-svc"
  engine               = "memcached"
  engine_version       = "1.6.17"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.vprofile-memcached-para-grp.name
  subnet_group_name    = aws_elasticache_subnet_group.vprofile-memcached-sub-group.name
  security_group_ids   = [aws_security_group.vprofile-backend-SG.id]

  tags = {
    Name        = "vprofile-elasticache-svc"
    Description = "ElastiCache cluster for vprofile"
  }
}

resource "random_password" "rabbitmq_password" {
  length  = 16
  special = true
}

resource "aws_mq_broker" "vprofile-rmq" {
  broker_name           = "vprofile-rmq"
  engine_type           = "RabbitMQ"
  engine_version        = "3.13"
  host_instance_type    = "mq.t3.micro"
  publicly_accessible   = false
  security_groups       = [aws_security_group.vprofile-backend-SG.id]
  subnet_ids            = [data.aws_subnet.single.id]
  auto_minor_version_upgrade = true

  user {
    username = "rabbit"
    password = random_password.rabbitmq_password.result
  }

  logs {
    general = true
  }

  tags = {
    Name = "vprofile-rmq"
  }
}

resource "local_file" "rabbitmq_password_file" {
  content  = random_password.rabbitmq_password.result
  filename = "${path.module}/key/rabbitmq_password.txt"
}