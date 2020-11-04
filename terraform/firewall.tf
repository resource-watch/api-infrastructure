// DEFAUlT Security Group
// SSH in From WRI office, 80 and 443 out

resource "aws_security_group" "default" {
  vpc_id = module.vpc.id

  tags = merge(
    {
      Name = "${var.project}-sgDefault"
    },
    local.tags
  )
}


resource "aws_security_group_rule" "default_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ingress_allow_cidr_block]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_ssh_egress" {
  type      = "egress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
  module.vpc.cidr_block]

  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_http_egress" {
  type             = "egress"
  from_port        = "80"
  to_port          = "80"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_https_egress" {
  type             = "egress"
  from_port        = "443"
  to_port          = "443"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}



// DocumentDB Access Security Group
// Allow to forward request to document DB

resource "aws_security_group" "postgresql" {
  vpc_id = module.vpc.id

  tags = merge(
    {
      Name = "${var.project}-sgBastionPostgreSQL"
    },
    local.tags
  )
}


resource "aws_security_group_rule" "postgres_port_forward_egress" {
  type                     = "egress"
  from_port                = module.postgresql.port
  to_port                  = module.postgresql.port
  protocol                 = "-1"
  source_security_group_id = module.postgresql.security_group_id
  security_group_id        = aws_security_group.postgresql.id
}