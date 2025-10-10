#!/bin/bash
USER="sysadmin"
SENHA="123"

echo "Criando um novo $USER"
sudo useradd -m -s /bin/bash $USER
echo "$USER:$SENHA" | sudo chpasswd

# dando permissão ssh
sudo mkdir -p /home/$USER/.ssh
sudo cp /home/ubuntu/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
sudo chown $USER:$USER /home/$USER/.ssh/authorized_keys
sudo chmod 600 /home/$USER/.ssh/authorized_keys
sudo chmod 700 /home/$USER/.ssh
echo "Permissão ssh concedida"

# atualizando e baixando pacotes
echo "Atualizando pacotes"
sudo apt update -y

echo "Instalando MySql"
sudo apt install -y mysql-server

echo "Instalando NodeJs e npm"
sudo apt install -y nodejs npm

echo "Instalando Python e Pip"
sudo apt install -y python3 python3-pip

echo "Ambiente configurado."

# 