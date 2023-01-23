data "aws_caller_identity" "current" {}

data "aws_ami" "latest-ubuntu-lts" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script to bootstrap authorized ssh keys
data "template_file" "bastion_setup" {
  template = file("${path.module}/templates/bastion_setup.sh.tpl")
  vars = {
    user       = "ubuntu"
    kubeconfig = module.eks.kubeconfig
    hostname   = "${var.environment}-bastion"
    authorized_ssh_keys = <<EOT
%{for row in formatlist("echo \"%v\" >> /home/ubuntu/.ssh/authorized_keys",
values(aws_key_pair.all)[*].public_key)~}
${row}
%{endfor~}
EOT
}
}

# User data script to bootstrap authorized ssh keys
data "template_file" "jenkins_config_on_ubuntu" {
  template = file("${path.module}/templates/jenkins_setup.sh.tpl")
  vars = {
    user       = "ubuntu"
    dns_prefix = var.dns_prefix
    authorized_ssh_keys = <<EOT
%{for row in formatlist("echo \"%v\" >> /home/ubuntu/.ssh/authorized_keys",
values(aws_key_pair.all)[*].public_key)~}
${row}
%{endfor~}
EOT
nginx_jenkins_host = <<EOT
server {
	server_name jenkins.${var.dns_prefix}.resourcewatch.org;
	location / {
	    proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
	}
}
EOT
}
}
