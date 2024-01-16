variable "env" { }
variable "component" { }

variable "tags" {}
variable "subnets" {}
variable "vpc_id" {}
variable "app_port" {}
variable "sg_subnet_cidr" {}
variable "kms_id" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}
variable "instance_type" {}
variable "allow_ssh_cidr" {}

variable "lb_dns_name" {}
variable "listener_arn" {}
variable "priority" {}
variable "kms_key_arn" {}
variable "extra_param_access" {}
variable "allow_prometheus_cidr" {}