# Data sources to look up existing VPC and subnets
data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Tier = var.subnet_tag_tier
  }
}
