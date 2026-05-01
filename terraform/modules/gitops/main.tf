locals {
  datadog_enabled           = var.datadog_api_key != ""
  image_pull_secret_enabled = var.image_pull_secret_server != "" && var.image_pull_secret_username != "" && var.image_pull_secret_password != ""
  effective_external_dns_domain_filters = length(var.external_dns_domain_filters) > 0 ? var.external_dns_domain_filters : [var.route53_zone_name]
  argocd_admin_password               = var.argocd_admin_password != "" ? var.argocd_admin_password : random_password.argocd_admin[0].result
  monitoring_namespace               = "monitoring"
  grafana_admin_password             = random_password.grafana_admin.result
  route53_zone_id                     = var.create_route53_zone ? aws_route53_zone.primary[0].zone_id : data.aws_route53_zone.primary[0].zone_id
  argocd_effective_certificate_arn    = var.argocd_acm_certificate_arn != "" ? var.argocd_acm_certificate_arn : aws_acm_certificate_validation.argocd[0].certificate_arn
  argocd_scheme                       = local.argocd_effective_certificate_arn != "" ? "https" : "http"
  argocd_url                          = "${local.argocd_scheme}://${var.argocd_hostname}"
  grafana_effective_certificate_arn   = var.grafana_acm_certificate_arn != "" ? var.grafana_acm_certificate_arn : aws_acm_certificate_validation.grafana[0].certificate_arn
  grafana_scheme                      = local.grafana_effective_certificate_arn != "" ? "https" : "http"
  grafana_url                         = "${local.grafana_scheme}://${var.grafana_hostname}"
  argocd_ingress_annotations = merge(
    {
      "alb.ingress.kubernetes.io/backend-protocol"           = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports"               = "[{\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/scheme"                     = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"                = "ip"
      "external-dns.alpha.kubernetes.io/hostname"            = var.argocd_hostname
    },
    local.argocd_effective_certificate_arn != "" ? {
      "alb.ingress.kubernetes.io/certificate-arn" = local.argocd_effective_certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\":80},{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
    } : {}
  )
  grafana_ingress_annotations = merge(
    {
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "external-dns.alpha.kubernetes.io/hostname"  = var.grafana_hostname
    },
    local.grafana_effective_certificate_arn != "" ? {
      "alb.ingress.kubernetes.io/certificate-arn" = local.grafana_effective_certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\":80},{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
    } : {}
  )
}

resource "random_password" "argocd_admin" {
  count            = var.argocd_admin_password == "" ? 1 : 0
  length           = 24
  special          = true
  override_special = "!@#%^*-_=+"
}

resource "random_password" "grafana_admin" {
  length           = 24
  special          = true
  override_special = "!@#%^*-_=+"
}

resource "aws_route53_zone" "primary" {
  count = var.create_route53_zone ? 1 : 0
  name  = var.route53_zone_name
}

data "aws_route53_zone" "primary" {
  count        = var.create_route53_zone ? 0 : 1
  name         = "${trim(var.route53_zone_name, ".")}."
  private_zone = false
}

resource "aws_acm_certificate" "argocd" {
  count             = var.argocd_acm_certificate_arn == "" ? 1 : 0
  domain_name       = var.argocd_hostname
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "argocd_certificate_validation" {
  for_each = var.argocd_acm_certificate_arn == "" ? {
    for option in aws_acm_certificate.argocd[0].domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.route53_zone_id
}

resource "aws_acm_certificate_validation" "argocd" {
  count                   = var.argocd_acm_certificate_arn == "" ? 1 : 0
  certificate_arn         = aws_acm_certificate.argocd[0].arn
  validation_record_fqdns = [for record in aws_route53_record.argocd_certificate_validation : record.fqdn]
}

resource "aws_acm_certificate" "grafana" {
  count             = var.grafana_acm_certificate_arn == "" ? 1 : 0
  domain_name       = var.grafana_hostname
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "grafana_certificate_validation" {
  for_each = var.grafana_acm_certificate_arn == "" ? {
    for option in aws_acm_certificate.grafana[0].domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.route53_zone_id
}

resource "aws_acm_certificate_validation" "grafana" {
  count                   = var.grafana_acm_certificate_arn == "" ? 1 : 0
  certificate_arn         = aws_acm_certificate.grafana[0].arn
  validation_record_fqdns = [for record in aws_route53_record.grafana_certificate_validation : record.fqdn]
}

resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_controller_role_arn
    }
  }
}

resource "kubernetes_service_account_v1" "ebs_csi_controller" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.ebs_csi_role_arn
    }
  }
}

resource "kubernetes_service_account_v1" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.external_dns_role_arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  namespace        = "kube-system"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = "1.13.0"
  create_namespace = false

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account_v1.aws_load_balancer_controller.metadata[0].name
    }
  ]
}

resource "helm_release" "aws_ebs_csi_driver" {
  name             = "aws-ebs-csi-driver"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  version          = "2.44.0"
  create_namespace = false

  set = [
    {
      name  = "controller.serviceAccount.create"
      value = "false"
    },
    {
      name  = "controller.serviceAccount.name"
      value = kubernetes_service_account_v1.ebs_csi_controller.metadata[0].name
    }
  ]
}

resource "helm_release" "datadog" {
  count            = local.datadog_enabled ? 1 : 0
  name             = "datadog"
  namespace        = "datadog"
  repository       = "https://helm.datadoghq.com"
  chart            = "datadog"
  version          = "3.119.0"
  create_namespace = true

  set = [
    {
      name  = "datadog.site"
      value = var.datadog_site
    },
    {
      name  = "datadog.clusterName"
      value = var.cluster_name
    },
    {
      name  = "clusterAgent.enabled"
      value = "true"
    }
  ]

  set_sensitive = [
    {
      name  = "datadog.apiKey"
      value = var.datadog_api_key
    },
    {
      name  = "datadog.appKey"
      value = var.datadog_app_key
    }
  ]
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  version          = "1.18.0"
  create_namespace = false

  values = [yamlencode({
    provider      = "aws"
    txtOwnerId    = var.external_dns_txt_owner_id
    sources       = ["service", "ingress"]
    domainFilters = local.effective_external_dns_domain_filters
    serviceAccount = {
      create = false
      name   = kubernetes_service_account_v1.external_dns.metadata[0].name
    }
  })]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  create_namespace = true

  depends_on = [aws_acm_certificate_validation.argocd]

  set_sensitive = [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = bcrypt(local.argocd_admin_password)
    }
  ]

  values = [yamlencode({
    global = {
      domain = var.argocd_hostname
    }
    configs = {
      cm = {
        url = local.argocd_url
      }
      params = {
        "server.insecure" = true
      }
    }
    server = {
      service = {
        type = "ClusterIP"
      }
      ingress = {
        enabled          = true
        controller       = "aws"
        hostname         = var.argocd_hostname
        ingressClassName = "alb"
        annotations      = local.argocd_ingress_annotations
        tls              = local.argocd_effective_certificate_arn != ""
        aws = {
          serviceType            = "ClusterIP"
          backendProtocolVersion = "HTTP"
        }
      }
    }
  })]
}

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = "3.12.2"
  create_namespace = false

  values = [yamlencode({
    args = [
      "--kubelet-insecure-tls",
      "--kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP"
    ]
  })]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = local.monitoring_namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  create_namespace = true

  values = [yamlencode({
    alertmanager = {
      enabled = false
    }
    kubeStateMetrics = {
      enabled = true
    }
    prometheus-node-exporter = {
      enabled = true
    }
    server = {
      persistentVolume = {
        enabled = false
      }
      service = {
        type = "ClusterIP"
      }
    }
  })]
}

resource "helm_release" "loki" {
  name             = "loki"
  namespace        = local.monitoring_namespace
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  create_namespace = true

  values = [yamlencode({
    grafana = {
      enabled = false
    }
    loki = {
      persistence = {
        enabled = false
      }
      service = {
        type = "ClusterIP"
      }
    }
    promtail = {
      enabled = true
    }
    fluent-bit = {
      enabled = false
    }
    filebeat = {
      enabled = false
    }
  })]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  namespace        = local.monitoring_namespace
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  create_namespace = true

  depends_on = [helm_release.prometheus, helm_release.loki, aws_acm_certificate_validation.grafana]

  set_sensitive = [
    {
      name  = "adminPassword"
      value = local.grafana_admin_password
    }
  ]

  values = [yamlencode({
    persistence = {
      enabled = false
    }
    service = {
      type = "ClusterIP"
    }
    ingress = {
      enabled          = true
      ingressClassName = "alb"
      annotations      = local.grafana_ingress_annotations
      hosts             = [var.grafana_hostname]
      path              = "/"
      pathType          = "Prefix"
      tls               = []
    }
    datasources = {
      "datasources.yaml" = {
        apiVersion = 1
        datasources = [
          {
            name      = "Prometheus"
            type      = "prometheus"
            access    = "proxy"
            url       = "http://prometheus-server.${local.monitoring_namespace}.svc.cluster.local"
            isDefault = true
          },
          {
            name   = "Loki"
            type   = "loki"
            access = "proxy"
            url    = "http://loki.${local.monitoring_namespace}.svc.cluster.local:3100"
          }
        ]
      }
    }
  })]
}

resource "kubernetes_secret_v1" "image_pull_secret" {
  count = local.image_pull_secret_enabled ? 1 : 0

  metadata {
    name      = var.image_pull_secret_name
    namespace = var.image_pull_secret_namespace
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.image_pull_secret_server) = {
          username = var.image_pull_secret_username
          password = var.image_pull_secret_password
          email    = var.image_pull_secret_email
          auth     = base64encode("${var.image_pull_secret_username}:${var.image_pull_secret_password}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}
