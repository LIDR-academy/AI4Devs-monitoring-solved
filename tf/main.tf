terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

# Configuración del proveedor de AWS
provider "aws" {
  region = "us-east-1" # Cambia a la región donde están tus instancias EC2
}

# Configuración del proveedor de Datadog
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  # Configura la región de Datadog
  api_url = "https://api.us5.datadoghq.com"
}

# Variables de entorno para las claves de Datadog
variable "datadog_api_key" {
  description = "API Key para Datadog"
  type        = string
}

variable "datadog_app_key" {
  description = "App Key para Datadog"
  type        = string
}

# Política de IAM para permitir a Datadog acceder a CloudWatch
resource "aws_iam_policy" "datadog_policy" {
  name        = "DatadogPolicy"
  description = "Política para permitir a Datadog acceder a CloudWatch"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "ec2:DescribeInstances",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ],
        "Resource": "*"
      }
    ]
  })
}

# Obtener los nombres de las instancias EC2 automáticamente
data "aws_instances" "all" {
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# Crear un dashboard en Datadog
resource "datadog_dashboard" "ec2_dashboard" {
  title       = "EC2 Monitoring Dashboard"
  description = "Dashboard para monitorizar instancias EC2"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "CPU Utilization"
      request {
        q = "avg:aws.ec2.cpuutilization{*} by {instance_id}"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Network In"
      request {
        q = "avg:aws.ec2.network_in{*} by {instance_id}"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Network Out"
      request {
        q = "avg:aws.ec2.network_out{*} by {instance_id}"
      }
    }
  }
}
