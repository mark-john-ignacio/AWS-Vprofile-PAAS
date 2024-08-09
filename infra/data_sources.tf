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

data "aws_subnet" "single" {
  id = data.aws_subnets.all.ids[0]  # Manually specify one subnet from the list
}