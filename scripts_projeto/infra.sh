#!/bin/bash

CHAVE="contoso"
EXTENSAO_CHAVE=".pem"

# checando o ID da VPC e colocando em variável
echo "Pegando o ID da VPC"
VPC=$(aws ec2 describe-vpcs \
--query "Vpcs[0].VpcId" \
--output text)

# checando ID da sub-rede e colocando em variável
echo "Pegando o ID da sub-rede"
SUB_NET=$(aws ec2 describe-subnets \
--query "Subnets[0].SubnetId" \
--output text)

# criação do par de chaves
echo "Criando o par de chaves"
aws ec2 create-key-pair \
  --key-name $CHAVE \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > ~/$CHAVE$EXTENSAO_CHAVE

chmod 400 ~/$CHAVE$EXTENSAO_CHAVE

# criação do grupo de segurança
echo "Criando o grupo de segurança"
SECURITY_ID=$(aws ec2 create-security-group \
  --group-name launch-dragon1 \
  --description "grupo_de_seguranca_01" \
  --vpc-id $VPC \
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=sg-042}]" \
  --query 'GroupId' \
  --output text \
  --region us-east-1)

# criação de regra de entrada no grupo de segurança
echo "Criando as regras de entrada no grupo de segurança"
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# criação das instâncias 
echo "Criando a instância"
aws ec2 run-instances \
--image-id ami-0360c520857e3138f \
--count 1 \
--security-group-ids $SECURITY_ID \
--instance-type t3.small \
--subnet-id $SUB_NET \
--key-name $CHAVE \
--block-device-mappings \
'[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":20,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-01}]'