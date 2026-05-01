module "networking" {
  source       = "./modules/networking"
  cluster_name = var.cluster_name
}
module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}
module "eks" {
  source                    = "./modules/eks"
  cluster_name              = var.cluster_name
  cluster_role_arn          = module.iam.eks_cluster_role_arn
  node_role_arn             = module.iam.eks_node_role_arn
  vpc_id                    = module.networking.vpc_id
  private_subnet_ids        = module.networking.private_subnet_ids
  private_security_group_id = module.sg.private_security_group_id
}
module "iam_addons" {
  source                   = "./modules/iam"
  cluster_name             = var.cluster_name
  create_eks_base_roles    = false
  create_irsa_roles        = true
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
}
module "ecr" {
  source                   = "./modules/ecr"
  backend_repository_name  = var.backend_ecr_repository_name
  frontend_repository_name = var.frontend_ecr_repository_name
  image_retention_count    = var.ecr_image_retention_count
}
module "gitops" {
  source                      = "./modules/gitops"
  cluster_name                = var.cluster_name
  aws_region                  = var.aws_region
  vpc_id                      = module.networking.vpc_id
  alb_controller_role_arn     = module.iam_addons.aws_load_balancer_controller_role_arn
  ebs_csi_role_arn            = module.iam_addons.ebs_csi_role_arn
  external_dns_role_arn       = module.iam_addons.external_dns_role_arn
  datadog_api_key             = var.datadog_api_key
  datadog_app_key             = var.datadog_app_key
  datadog_site                = var.datadog_site
  external_dns_domain_filters = var.external_dns_domain_filters
  external_dns_txt_owner_id   = var.external_dns_txt_owner_id
  route53_zone_name           = var.route53_zone_name
  create_route53_zone         = var.create_route53_zone
  argocd_hostname             = var.argocd_hostname
  argocd_admin_password       = var.argocd_admin_password
  argocd_acm_certificate_arn  = var.argocd_acm_certificate_arn
  grafana_hostname            = var.grafana_hostname
  grafana_acm_certificate_arn = var.grafana_acm_certificate_arn
  image_pull_secret_name      = var.image_pull_secret_name
  image_pull_secret_namespace = var.image_pull_secret_namespace
  image_pull_secret_server    = var.image_pull_secret_server
  image_pull_secret_username  = var.image_pull_secret_username
  image_pull_secret_password  = var.image_pull_secret_password
  image_pull_secret_email     = var.image_pull_secret_email
}
module "sg" {
  source = "./modules/sg"
  vpc_id = module.networking.vpc_id
}
module "alb" {
  source                = "./modules/alb"
  alb_security_group_id = module.sg.alb_security_group_id
  subnet_ids            = module.networking.public_subnet_ids
}


