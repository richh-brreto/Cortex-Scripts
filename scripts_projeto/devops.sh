#!/bin/bash

CHAVE="cortex"
EXTENSAO_CHAVE=".pem"
REGIAO="us-east-1"
NOME_GRUPO="launch-dragon1"
TIPO_INSTANCIA="t3.small"
NOME_INSTANCIA="mysql-server"
USER_DATA="./sfw.sh"
IAM_ROLE="LabInstanceProfile"

# checando o ID da VPC e colocando em variável
echo "Pegando o ID da VPC..."
VPC=$(aws ec2 describe-vpcs \
--query "Vpcs[0].VpcId" \
--output text)

# checando ID da sub-rede e colocando em variável
echo "Pegando o ID da sub-rede..."
SUB_NET=$(aws ec2 describe-subnets \
--query "Subnets[0].SubnetId" \
--output text)

if [ -e "./$CHAVE$EXTENSAO_CHAVE" ]; then
  echo "O par de chaves $CHAVE já existe, usando o arquivo existente."
  chmod 400 ./$CHAVE$EXTENSAO_CHAVE
  else
# criação do par de chaves
echo "Criando o par de chaves..."
# caso apareça erro de par de chaves duplicada ou ja existente, verificar se o arquivo .pem já existe tanto localmente quanto na AWS
aws ec2 create-key-pair \
  --key-name $CHAVE \
  --region $REGIAO \
  --query 'KeyMaterial' \
  --output text | sed 's/\r$//' > ./$CHAVE$EXTENSAO_CHAVE

chmod 400 ./$CHAVE$EXTENSAO_CHAVE
fi

# criação do grupo de segurança
echo "Verificando se o grupo de segurança $NOME_GRUPO já existe..."
SECURITY_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=$NOME_GRUPO" \
  --query "SecurityGroups[0].GroupId" \
  --output text \
  --region $REGIAO)

if [ "$SECURITY_ID" != "None" ] && [ -n "$SECURITY_ID" ]; then
  echo "O grupo de segurança $NOME_GRUPO já existe. Usando o ID: $SECURITY_ID"
else
  echo "Criando o grupo de segurança..."
  SECURITY_ID=$(aws ec2 create-security-group \
    --group-name $NOME_GRUPO \
    --description "grupo_de_seguranca_01" \
    --vpc-id $VPC \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=sg-042}]" \
    --query 'GroupId' \
    --output text \
    --region us-east-1)
  echo "Grupo de segurança criado com ID: $SECURITY_ID"

  # criação de regra de entrada no grupo de segurança
  echo "Criando as regras de entrada no grupo de segurança..."
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

  aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_ID \
    --protocol tcp \
    --port 3306 \
    --cidr 0.0.0.0/0
fi

echo "Usando grupo de segurança: $SECURITY_ID"

# criação das instâncias 
echo "Criando a instância"
aws ec2 run-instances \
--image-id ami-0360c520857e3138f \
--count 1 \
--security-group-ids $SECURITY_ID \
--instance-type $TIPO_INSTANCIA \
--subnet-id $SUB_NET \
--key-name $CHAVE \
--iam-instance-profile Name="$IAM_ROLE" \
--user-data file://$USER_DATA \
--block-device-mappings \
'[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":20,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='"$NOME_INSTANCIA"'}]' \

echo "Instância criada com sucesso!"