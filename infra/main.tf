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

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.mysql-client-sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

# resource "aws_db_instance" "vprofile-rds-mysql" {
#   identifier              = "vprofile-rds-mysql"
#   engine                  = "mysql"
#   engine_version          = "8.0.32"
#   instance_class          = "db.t3.micro"
#   allocated_storage       = 20
#   storage_type            = "gp2"
#   db_subnet_group_name    = aws_db_subnet_group.vprofile-rds-sub-grp.name
#   vpc_security_group_ids  = [aws_security_group.vprofile-backend-SG.id]
#   publicly_accessible     = false
#   auto_minor_version_upgrade = true
#   backup_retention_period = 7
#   monitoring_interval     = 60
#   monitoring_role_arn     = aws_iam_role.rds_monitoring.arn
#   parameter_group_name    = aws_db_parameter_group.vprofile-para-grp.name
#   apply_immediately       = true
#   skip_final_snapshot     = true

#   db_name                    = "accounts"
#   username                = "admin"
#   password                = random_password.rds_password.result

#   tags = {
#     Name = "vprofile-rds-mysql"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }

#   depends_on = [aws_iam_role_policy_attachment.rds_monitoring]
# }

resource "random_password" "rds_password" {
  length  = 16
  special = true
  override_special = "_-=#"
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
  engine_version        = "3.13.6"
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

# resource "aws_instance" "sql_executor" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   key_name      = aws_key_pair.vprofile-bean-key.key_name
#   subnet_id     = data.aws_subnet.single.id
#   vpc_security_group_ids = [aws_security_group.mysql-client-sg.id]

#   provisioner "file" {
#     source      = "sql/db_backup.sql"
#     destination = "/tmp/file.sql"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(local_file.private-key.filename)
#       host        = self.public_ip
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update -y",
#       "sudo apt-get install -y mysql-client",
#       "mysql -h ${aws_db_instance.vprofile-rds-mysql.address} -u ${aws_db_instance.vprofile-rds-mysql.username} -p${random_password.rds_password.result} ${aws_db_instance.vprofile-rds-mysql.db_name} < /tmp/file.sql",
#       "mysql -h ${aws_db_instance.vprofile-rds-mysql.address} -u ${aws_db_instance.vprofile-rds-mysql.username} -p${random_password.rds_password.result} -e 'SHOW TABLES;' ${aws_db_instance.vprofile-rds-mysql.db_name} > /tmp/sql_output.txt"
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(local_file.private-key.filename)
#       host        = self.public_ip
#     }
#   }

#   provisioner "local-exec" {
#     command = "scp -i ${local_file.private-key.filename} ubuntu@${self.public_ip}:/tmp/sql_output.txt sql/sql_output.txt"
#   }

#   tags = {
#     Name = "sql-executor"
#   }

#   depends_on = [aws_db_instance.vprofile-rds-mysql, local_file.private-key]
# }


resource "aws_security_group" "mysql-client-sg" {
  name = "mysql-client-sg"
  description = "Security group for MySQL client"

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${trimspace(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 
}
// Beanstalk role
resource "aws_iam_role" "vprofile_bean_role" {
  name = "vprofile-bean-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vprofile_bean_role_attach_1" {
  role       = aws_iam_role.vprofile_bean_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "vprofile_bean_role_attach_2" {
  role       = aws_iam_role.vprofile_bean_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}


resource "aws_iam_role_policy_attachment" "vprofile_bean_role_attach_4" {
  role       = aws_iam_role.vprofile_bean_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkCustomPlatformforEC2Role"
}

# Define the Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "vprofile_app" {
  name        = "vprofile-app"
  description = "vprofile application"
}

# Define the Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "vprofile_app_prod" {
  name                = "vprofile-app-prod"
  application         = aws_elastic_beanstalk_application.vprofile_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.0 running Corretto 21"
  cname_prefix        = "vprofile-mark-abc123"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "vprofile-bean-role"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "vprofile-bean-key"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "8"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.default.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    #exclude the subnet that is not available us-east-1e
    value     = join(",", [for id in data.aws_subnets.all.ids : id if id != data.aws_subnet.exclude.id])
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EnvironmentVariables"
    value     = "Name=vproapp,Project=vprofile-saas"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "50"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Percentage"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "80"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessLBCookieDuration"
    value     = "86400"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "LoadBalancerIsPublic"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "LoadBalancerSubnets"
    value     = join(",", data.aws_subnets.all.ids)
   }

  tags = {
    Name    = "vproapp"
    Project = "vprofile-saas"
  }
}