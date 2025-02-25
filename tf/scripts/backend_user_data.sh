#!/bin/bash
export DD_AGENT_MAJOR_VERSION=7 
export DD_API_KEY='76cd5e07d41cec7b205a01ffbc26c5ae'
export DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

yum update -y
yum install -y docker

# Iniciar el servicio de Docker
sudo service docker start
rm -rf /home/ec2-user/backend
# Descargar y descomprimir el archivo backend.zip desde S3
aws s3 cp s3://bucket-lti-project-code/backend.zip /home/ec2-user/backend.zip
unzip /home/ec2-user/backend.zip -d /home/ec2-user/

# Construir la imagen Docker para el backend
cd /home/ec2-user/backend
sudo docker build -t lti-backend .

# Ejecutar el contenedor Docker
sudo docker run -d -p 8080:8080 lti-backend

# Timestamp to force update
echo "Timestamp: ${timestamp}"
