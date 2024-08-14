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

data "aws_subnet" "exclude" {
  filter {
    name   = "availability-zone"
    values = ["us-east-1e"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "single" {
  id = data.aws_subnets.all.ids[0]  # Manually specify one subnet from the list
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "is-public"
    values = ["true"]
  }
}


data "aws_s3_bucket" "vprofile_app_prod_bucket" {
  bucket = "elasticbeanstalk-${aws_elastic_beanstalk_environment.vprofile_app_prod.region}-${data.aws_elastic_beanstalk_environment.vprofile_app_prod.environment_id}"
}