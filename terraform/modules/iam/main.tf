data "aws_iam_policy_document" "eks_cluster_assume_role" {
  count = var.create_eks_base_roles ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  count = var.create_eks_base_roles ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster" {
  count              = var.create_eks_base_roles ? 1 : 0
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role[0].json
}

resource "aws_iam_role" "eks_node_group" {
  count              = var.create_eks_base_roles ? 1 : 0
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.create_eks_base_roles ? 1 : 0
  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  count      = var.create_eks_base_roles ? 1 : 0
  role       = aws_iam_role.eks_node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  count      = var.create_eks_base_roles ? 1 : 0
  role       = aws_iam_role.eks_node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_policy" {
  count      = var.create_eks_base_roles ? 1 : 0
  role       = aws_iam_role.eks_node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "tls_certificate" "eks_oidc" {
  count = var.create_irsa_roles ? 1 : 0
  url   = var.oidc_provider_issuer_url
}

data "tls_certificate" "github_actions_oidc" {
  count = var.create_github_actions_role && var.create_github_actions_oidc_provider ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

data "aws_caller_identity" "current" {
  count = var.create_github_actions_role ? 1 : 0
}

resource "aws_iam_openid_connect_provider" "eks" {
  count           = var.create_irsa_roles ? 1 : 0
  url             = var.oidc_provider_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc[0].certificates[0].sha1_fingerprint]
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count           = var.create_github_actions_role && var.create_github_actions_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions_oidc[0].certificates[0].sha1_fingerprint]
}

locals {
  github_actions_oidc_provider_arn = !var.create_github_actions_role ? null : (
    var.create_github_actions_oidc_provider
    ? aws_iam_openid_connect_provider.github_actions[0].arn
    : "arn:aws:iam::${data.aws_caller_identity.current[0].account_id}:oidc-provider/token.actions.githubusercontent.com"
  )
  github_actions_oidc_subjects = !var.create_github_actions_role ? [] : (
    length(var.github_actions_oidc_subjects) > 0 ? var.github_actions_oidc_subjects : [
      "repo:${var.github_repository}:ref:refs/heads/main",
      "repo:${var.github_repository}:ref:refs/heads/terraform",
      "repo:${var.github_repository}:pull_request",
    ]
  )
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  count = var.create_github_actions_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_actions_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_actions_oidc_subjects
    }
  }
}

data "aws_iam_policy_document" "github_actions_ecr_push" {
  count = var.create_github_actions_role ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = var.github_actions_ecr_repository_arns
  }
}

resource "aws_iam_policy" "github_actions_ecr_push" {
  count       = var.create_github_actions_role ? 1 : 0
  name        = "${var.github_actions_role_name}-ecr-push"
  description = "Minimal ECR push policy for GitHub Actions"
  policy      = data.aws_iam_policy_document.github_actions_ecr_push[0].json
}

resource "aws_iam_role" "github_actions" {
  count              = var.create_github_actions_role ? 1 : 0
  name               = var.github_actions_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_push" {
  count      = var.create_github_actions_role ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.github_actions_ecr_push[0].arn
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
  count = var.create_irsa_roles ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  count = var.create_irsa_roles ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

data "aws_iam_policy_document" "external_dns_assume_role" {
  count = var.create_irsa_roles ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }
  }
}
data "aws_iam_policy_document" "aws_load_balancer_controller" {
  count = var.create_irsa_roles ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "cognito-idp:DescribeUserPoolClient",
      "ec2:AllocateAddress",
      "ec2:AssociateAddress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteTags",
      "ec2:Describe*",
      "ec2:DisassociateAddress",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:*",
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:ListProtections",
      "tag:GetResources",
      "tag:TagResources",
      "waf:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  count       = var.create_irsa_roles ? 1 : 0
  name        = "${var.cluster_name}-aws-load-balancer-controller"
  description = "Policy for the AWS Load Balancer Controller"
  policy      = data.aws_iam_policy_document.aws_load_balancer_controller[0].json
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  count              = var.create_irsa_roles ? 1 : 0
  name               = "${var.cluster_name}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  count      = var.create_irsa_roles ? 1 : 0
  role       = aws_iam_role.aws_load_balancer_controller[0].name
  policy_arn = aws_iam_policy.aws_load_balancer_controller[0].arn
}

resource "aws_iam_role" "ebs_csi" {
  count              = var.create_irsa_roles ? 1 : 0
  name               = "${var.cluster_name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count      = var.create_irsa_roles ? 1 : 0
  role       = aws_iam_role.ebs_csi[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_iam_policy_document" "external_dns" {
  count = var.create_irsa_roles ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  count       = var.create_irsa_roles ? 1 : 0
  name        = "${var.cluster_name}-external-dns"
  description = "Policy for ExternalDNS"
  policy      = data.aws_iam_policy_document.external_dns[0].json
}

resource "aws_iam_role" "external_dns" {
  count              = var.create_irsa_roles ? 1 : 0
  name               = "${var.cluster_name}-external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  count      = var.create_irsa_roles ? 1 : 0
  role       = aws_iam_role.external_dns[0].name
  policy_arn = aws_iam_policy.external_dns[0].arn
}
