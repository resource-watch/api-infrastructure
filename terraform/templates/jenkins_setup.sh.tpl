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
sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# Add users to the docker group so that they can use docker
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
# Configure docker daemon to listen on localhost:2375
sudo mkdir -p /etc/systemd/system/docker.service.d/
echo -e "[Service] \nExecStart= \nExecStart=/usr/bin/dockerd -H :2375" | sudo tee -a /etc/systemd/system/docker.service.d/docker.conf
sudo systemctl daemon-reload
sudo systemctl restart docker


#
# Install docker compose
#
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#
# Install Java
#
sudo apt install default-jre -y

#
# Install Jenkins
#
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins -y

#
# Install Nginx
#
sudo apt update
sudo apt install nginx -y
echo "${nginx_jenkins_host}" >> /etc/nginx/sites-enabled/jenkins
sudo systemctl restart nginx

#
# Install Nginx
#
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx -y
sudo certbot --nginx -n -m tiago.garcia@vizzuality.com --agree-tos --redirect --domains jenkins.${dns_prefix}.resourcewatch.org
sudo systemctl restart nginx

#
# Kubectl
#
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

#
# AWS CLI
#
sudo apt-get install -y python2.7
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python2.7 get-pip.py
sudo pip install awscli


#
# Install jenkins plugins
#
# This would need auth to work :(
# sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin email-ext kubernetes ssh