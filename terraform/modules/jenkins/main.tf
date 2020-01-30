

resource "aws_security_group" "jenkins_egress_security_group" {
  name        = "${replace(var.project, " ", "-")}-jenkins-egress-security-group"
  description = "Jenkins egress SG to the world"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${replace(var.project, " ", "-")}-jenkins-egress-security-group"
  }
}

resource "aws_security_group" "jenkins_ingress_security_group" {
  name        = "${replace(var.project, " ", "-")}-jenkins-ingress-security-group"
  description = "Jenkins ingress SG from the world"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${replace(var.project, " ", "-")}-jenkins-ingress-security-group"
  }
}

resource "aws_security_group_rule" "jenkins_ingress_https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS traffic to the Jenkins EC2 instance"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_ingress_security_group.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "jenkins_ingress_http" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP traffic to the Jenkins EC2 instance"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_ingress_security_group.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "jenkins_ingress_ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH traffic to the Jenkins EC2 instance"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_ingress_security_group.id
  to_port           = 22
  type              = "ingress"
}

#
# Jenkins EC2
#

resource "aws_instance" "jenkins" {
  ami                    = var.jenkins_ami
  availability_zone      = var.availability_zones[0]
  ebs_optimized          = true
  instance_type          = var.jenkins_instance_type
  monitoring             = true
  subnet_id              = var.subnet_id
  vpc_security_group_ids = concat(var.security_group_ids, [aws_security_group.jenkins_egress_security_group.id, aws_security_group.jenkins_ingress_security_group.id])
  associate_public_ip_address = true
  user_data                   = var.user_data

  root_block_device {
    volume_type = "gp2"
    volume_size = 150
    encrypted   = true
  }

  tags = merge(
    {
      Name = "${var.project}-jenkins"
    },
    var.tags
  )
}