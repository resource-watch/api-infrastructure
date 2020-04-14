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

# IAM role to access the EKS cluster
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins_profile"
  role = var.iam_instance_profile_role.name

  depends_on = [
    var.iam_instance_profile_role
  ]
}


#
# Jenkins EC2
#
resource "aws_instance" "jenkins" {
  ami                         = var.jenkins_ami
  availability_zone           = var.availability_zones[0]
  ebs_optimized               = true
  instance_type               = var.jenkins_instance_type
  monitoring                  = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = concat(var.security_group_ids, [aws_security_group.jenkins_egress_security_group.id, aws_security_group.jenkins_ingress_security_group.id])
  associate_public_ip_address = true
  user_data                   = var.user_data
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name

  lifecycle {
    ignore_changes = [user_data, ami]
  }

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

resource "aws_backup_plan" "jenkins_backup_plan" {
  name = "jenkins_backup_plan"

  rule {
    rule_name         = "jenkins_backup_rule"
    target_vault_name = aws_backup_vault.default_backup_vault.name
    schedule          = "cron(0 0 ? * SUN *)"
    lifecycle {
      delete_after = 120
    }
  }
}

resource "aws_backup_vault" "default_backup_vault" {
  name = "default_backup_vault"
}

resource "aws_iam_role" "backup_role" {
  name               = "backup_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "backup_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_backup_selection" "jenkins_backup_selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "jenkins_backup_selection"
  plan_id      = aws_backup_plan.jenkins_backup_plan.id

  resources = [
    aws_instance.jenkins.arn,
  ]
}
