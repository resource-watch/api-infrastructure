#!/bin/bash

#
# Public keys for ssh
#
touch /home/"${user}"/.ssh/authorized_keys

${authorized_ssh_keys}

chown ${user}: /home/"${user}"/.ssh/authorized_keys
chmod 0600 /home/"${user}"/.ssh/authorized_keys

sudo apt-get update
sudo apt-get upgrade -y

#
# Install docker
#
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce -y
sudo systemctl status docker
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

#
# Install docker compose
#

mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
sudo tee /usr/local/sbin/docker > /dev/null << EOT
#!/bin/bash
if [ "\$1" == "-H" ] && [ "\$2" == ":2375" ];
then
    /usr/bin/docker \$${*:3}
else
    /usr/bin/docker \$${*:1}
fi
EOT
sudo chmod +x /usr/local/sbin/docker

sudo tee /usr/local/sbin/docker-compose > /dev/null << EOT
#!/bin/bash
if [ "\$1" == "-H" ] && [ "\$2" == ":2375" ];
then
    /usr/bin/docker compose \$${*:3}
else
    /usr/bin/docker compose \$${*:1}
fi
EOT
sudo chmod +x /usr/local/sbin/docker-compose


#
# Install Java
#
sudo apt install default-jre -y

#
# Install Jenkins
#
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null'
sudo apt update -y
sudo apt install jenkins -y
sudo systemctl enable jenkins.service
sudo systemctl start jenkins.service
# Add jenkins user to the docker group so that they can use docker
sudo usermod -aG docker jenkins

#
# Install Nginx
#
sudo apt update
sudo apt install nginx -y
# Create a nginx config file for this site in /etc/nginx/sites-available
echo "${nginx_jenkins_host}" >> /etc/nginx/sites-enabled/jenkins
sudo systemctl restart nginx

#
# Install Certbot
#
sudo snap install core; sudo snap refresh core
sudo apt remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --agree-tos --nginx -d jenkins.${dns_prefix}.resourcewatch.org --register-unsafely-without-email
sudo systemctl start snap.certbot.renew.service
sudo systemctl enable snap.certbot.renew.service

#
# Kubectl
#
sudo apt-get install -y ca-certificates curl -y
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

#
# AWS CLI
#
sudo apt-get install -y unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
