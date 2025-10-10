#!/bin/bash
USER="sysadmin"
SENHA="123"
sudo apt update && sudo apt upgrade -y

# configuração do usuário sysadmin
sudo useradd -m -s /bin/bash $USER
sudo mkdir -p /home/$USER/.ssh
sudo cp /home/ubuntu/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
sudo chown $USER:$USER /home/$USER/.ssh/authorized_keys
sudo chmod 600 /home/$USER/.ssh/authorized_keys
sudo chmod 700 /home/$USER/.ssh

# instalação do MySQL, Node.js, Python e pip
sudo apt update -y
sudo apt install -y mysql-server
sudo apt install -y nodejs npm
sudo apt install -y python3 python3-pip

# instalação do Docker e configuração do docker
sudo apt-get update -y
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# adicionando o usuário ao grupo docker
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
# iniciando e habilitando o docker
sudo systemctl start docker
sudo systemctl enable docker

# instalação do AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install