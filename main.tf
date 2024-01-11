

#
#
##security group
#
#resource "aws_security_group" "sg" {
#  name        = "${var.component}-${var.env}-sg"
#  description = "${var.component}-${var.env}-sg"
#
#
#
#  ingress {
#    description = "ssh"
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#
#  }
#
#  egress {
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#
#  tags = {
#    Name = "${var.component}-${var.env}-sg"
#  }
#}
#
##ec2
#resource "aws_instance" "instance" {
#  ami                    = data.aws_ami.example.id
#  instance_type          = "t3.micro"
#  vpc_security_group_ids = [aws_security_group.sg.id]
#  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
#
#
#
#  tags = merge({
#    Name = "${var.component}-${var.env}"
#  }, var.tags)
#
#}
#
##dns record
#
#resource "aws_route53_record" "dns" {
#  zone_id = "Z02630002CU3WENE8SD4L"
#  name    = "${var.component}-dev"
#  type    = "A"
#  ttl     = 30
#  records = [aws_instance.instance.private_ip]
#}
#
### null resource in ansible
#
#resource "null_resource" "ansible" {
#  depends_on = [aws_instance.instance, aws_route53_record.dns]
#  provisioner "remote-exec" {
#
#    connection {
#      type     = "ssh"
#      user     = "centos"
#      password = "DevOps321"
#      host     = aws_instance.instance.public_ip
#    }
#
#
#    inline = [
#      "sudo labauto ansible",
#      "ansible-pull -i localhost, -U https://github.com/Gadilasruthilaya/roboshopshell-ansible-v1.git main.yml -e env=${var.env} -e role_name=${var.component}"
#    ]
#  }
#}


#resource "aws_security_group" "test" {
#  name        = "test-sg"
#  description = "test-sg"
#  vpc_id = var.vpc_id
#
#
#  ingress {
#    description = "ssh"
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#
#  }
#
#  egress {
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#
#  tags = {
#    Name = "test-sg"
#  }
#}
#resource "aws_instance" "instance" {
#  ami                    = data.aws_ami.example.id
#  instance_type          = "t3.micro"
#  vpc_security_group_ids = [aws_security_group.test.id]
#  subnet_id = var.subnet_id
#
#
#
#  tags ={
#    Name = "${var.component}"
#  }
#
#}

# app module code

resource "aws_security_group" "main" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id



  ingress {

    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.sg_subnet_cidr

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allow_ssh_cidr

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags =  merge({
    Name = "${var.component}-${var.env}"
  }, var.tags)
}

resource "aws_launch_template" "main" {
  name = "${var.component}-${var.env}-launch-template"



    iam_instance_profile {
      name = aws_iam_instance_profile.instance_profile.name
    }
    image_id                             = data.aws_ami.main.id
    instance_initiated_shutdown_behavior = "terminate"
    instance_type                        = var.instance_type
    vpc_security_group_ids               = [aws_security_group.main.id]
    tag_specifications {
      resource_type = "instance"

      tags = merge({
        Name = "${var.component}-${var.env}", monitor = "true"
      }, var.tags)
    }
    user_data = base64encode(templatefile("${path.module}/userdata.sh", {
      env       = var.env
      component = var.component
    }))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
      encrypted  = true
      kms_key_id = var.kms_id
    }
  }


  }


resource "aws_autoscaling_group" "main" {
  vpc_zone_identifier = var.subnets
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}


