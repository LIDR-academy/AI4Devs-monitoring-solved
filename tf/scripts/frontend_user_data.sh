#!/bin/bash
yum update -y
yum install -y docker
export DD_AGENT_MAJOR_VERSION=7 
export DD_API_KEY='76cd5e07d41cec7b205a01ffbc26c5ae'
export DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Iniciar el servicio de Docker
service docker start


sudo rm -rf /home/ec2-user/frontend
# Descargar y descomprimir el archivo frontend.zip desde S3
aws s3 cp s3://lti-project-code-bucket/frontend.zip /home/ec2-user/frontend.zip
unzip /home/ec2-user/frontend.zip -d /home/ec2-user/

# Construir la imagen Docker para el frontend
cd /home/ec2-user/frontend
docker build -t lti-frontend .

# Ejecutar el contenedor Docker
docker run -d -p 3000:3000 lti-frontend

# Timestamp to force update
echo "Timestamp: ${timestamp}"
