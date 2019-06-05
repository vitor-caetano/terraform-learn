provider "aws" {
  region = "us-east-1"
}

terraform {
    backend "s3" {
    bucket = "vitor-learn-terraform-state"
    key    = "vitor-learn/us-east-1"
    region = "us-east-1"
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "simple-example"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "megapool"
}

resource "aws_autoscaling_group" "cluster" {
  name                 = "megapool"
  vpc_zone_identifier  = module.vpc.private_subnets
  launch_configuration = "${aws_launch_configuration.cluster.name}"

  desired_capacity = 3
  min_size         = 3
  max_size         = 3
}

resource "aws_launch_configuration" "cluster" {
  name                 = "megapool"
  image_id             = "${data.aws_ami.ecs_optimized.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_agent.name}"
  user_data            = "${data.template_file.user_data.rendered}"
  instance_type        = "t2.micro"
}

data "aws_ami" "ecs_optimized" {
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20190510-x86_64-ebs"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.yaml")}"

  vars = {
    cluster_name = "megapool"
  }
}

# Define the role.
resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_agent.json}"
}

# Allow EC2 service to assume this role.
data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Give this role the permission to do ECS Agent things.
resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = "${aws_iam_role.ecs_agent.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = "${aws_iam_role.ecs_agent.name}"
}