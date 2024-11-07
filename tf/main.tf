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
  region = "us-east-2" # Cambia a la región donde están tus instancias EC2
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
"apigateway:GET",
                "autoscaling:Describe*",
                "backup:List*",
                "backup:ListRecoveryPointsByBackupVault",
                "bcm-data-exports:GetExport",
                "bcm-data-exports:ListExports",
                "budgets:ViewBudget",
                "cassandra:Select",
                "cloudfront:GetDistributionConfig",
                "cloudfront:ListDistributions",
                "cloudtrail:DescribeTrails",
                "cloudtrail:GetTrailStatus",
                "cloudtrail:LookupEvents",
                "cloudwatch:Describe*",
                "cloudwatch:Get*",
                "cloudwatch:List*",
                "codedeploy:BatchGet*",
                "codedeploy:List*",
                "cur:DescribeReportDefinitions",
                "directconnect:Describe*",
                "dynamodb:Describe*",
                "dynamodb:List*",
                "ec2:Describe*",
                "ec2:GetSnapshotBlockPublicAccessState",
                "ec2:GetTransitGatewayPrefixListReferences",
                "ec2:SearchTransitGatewayRoutes",
                "ecs:Describe*",
                "ecs:List*",
                "elasticache:Describe*",
                "elasticache:List*",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeTags",
                "elasticloadbalancing:Describe*",
                "elasticmapreduce:Describe*",
                "elasticmapreduce:List*",
                "es:DescribeElasticsearchDomains",
                "es:ListDomainNames",
                "es:ListTags",
                "events:CreateEventBus",
                "fsx:DescribeFileSystems",
                "fsx:ListTagsForResource",
                "glacier:GetVaultNotifications",
                "glue:ListRegistries",
                "health:DescribeAffectedEntities",
                "health:DescribeEventDetails",
                "health:DescribeEvents",
                "kinesis:Describe*",
                "kinesis:List*",
                "lambda:GetPolicy",
                "lambda:List*",
                "lightsail:GetInstancePortStates",
                "logs:DeleteSubscriptionFilter",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:DescribeSubscriptionFilters",
                "logs:FilterLogEvents",
                "logs:PutSubscriptionFilter",
                "logs:TestMetricFilter",
                "oam:ListAttachedLinks",
                "oam:ListSinks",
                "organizations:Describe*",
                "organizations:List*",
                "rds:Describe*",
                "rds:List*",
                "redshift:DescribeClusters",
                "redshift:DescribeLoggingStatus",
                "route53:List*",
                "s3:GetBucketLocation",
                "s3:GetBucketLogging",
                "s3:GetBucketNotification",
                "s3:GetBucketTagging",
                "s3:ListAccessGrants",
                "s3:ListAllMyBuckets",
                "s3:PutBucketNotification",
                "savingsplans:DescribeSavingsPlanRates",
                "savingsplans:DescribeSavingsPlans",
                "ses:Get*",
                "sns:GetSubscriptionAttributes",
                "sns:List*",
                "sns:Publish",
                "sqs:ListQueues",
                "states:DescribeStateMachine",
                "states:ListStateMachines",
                "support:DescribeTrustedAdvisor*",
                "support:RefreshTrustedAdvisorCheck",
                "tag:GetResources",
                "tag:GetTagKeys",
                "tag:GetTagValues",
                "timestream:DescribeEndpoints",
                "waf-regional:ListRuleGroups",
                "waf-regional:ListRules",
                "waf:ListRuleGroups",
                "waf:ListRules",
                "wafv2:GetIPSet",
                "wafv2:GetLoggingConfiguration",
                "wafv2:GetRegexPatternSet",
                "wafv2:GetRuleGroup",
                "wafv2:ListLoggingConfigurations",
                "xray:BatchGetTraces",
                "xray:GetTraceSummaries"
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

resource "datadog_monitor" "cpu_usage_alert" {
  name               = "High CPU Utilization Alert"
  type               = "metric alert"
  message            = "La utilización de CPU ha superado el 80% durante más de 5 minutos. Por favor, revisa la instancia."
  escalation_message = "La alerta de CPU sigue activa. Se requiere atención inmediata."
  query = "avg(last_5m):avg:aws.ec2.cpuutilization{instance_id in (${join(",", data.aws_instances.all.ids)})} > 80"
  # Configuración de notificaciones
  notify_no_data = false
  notify_audit   = false
  timeout_h      = 0
  # Configurar los umbrales del monitor
  monitor_thresholds {
    critical = 80
  }
  tags = [
    "environment:production",
    "team:operations"
  ]
}