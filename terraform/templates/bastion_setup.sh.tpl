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
# Set a hostname that identifies the cluster properly, so we avoid mistakes
#
hostnamectl set-hostname "${hostname}"

#
# Install kubectl
#
sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl


#
# Configure kubectl
#
mkdir /home/"${user}"/.kube
touch /home/"${user}"/.kube/config
cat >/home/"${user}"/.kube/config <<EOL
${kubeconfig}
EOL
chown "${user}":"${user}" -R /home/"${user}"/.kube
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl

#
# AWS CLI
#
sudo apt-get install -y python2.7
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python2.7 get-pip.py
sudo pip install awscli