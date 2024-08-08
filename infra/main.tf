data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

data "aws_vpc" "default" {
  id = "vpc-048c313786f7c4c19"
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name = "region-name"
    values = ["us-east-1"]
  }
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name = "availability-zone"
    values = data.aws_availability_zones.available.names
  }
}

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