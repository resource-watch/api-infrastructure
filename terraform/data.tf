data "aws_caller_identity" "current" {}


# Latest Amazon Linux Image (AMI)
data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners = [
  "amazon"]

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm*"]
  }
}

# User data script to bootstrap authorized ssh keys
data "template_file" "authorized_keys_ec2_user" {
  template = file("${path.module}/templates/authorized_keys.sh.tpl")
  vars = {
    user = "ec2-user"
    echo_rows = <<EOT
%{for row in formatlist("echo \"%v\" >> /home/ec2-user/.ssh/authorized_keys",
values(aws_key_pair.all)[*].public_key)~}
${row}
%{endfor~}
EOT
}
}


