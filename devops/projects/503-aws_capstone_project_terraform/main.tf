#------ root/main.tf ---


module "vpc" {
  source                     = "./modules/vpc"
  vpc_cidr                   = local.vpc_cidr
  access_ip                  = var.access_ip
  alb_security_group         = var.alb_security_group
  ec2_security_group         = var.ec2_security_group
  rds_security_group         = var.rds_security_group
  natinstance_security_group = var.natinstance_security_group
  public_sn_count            = 2
  private_sn_count           = 2
  max_subnets                = 20
  public_cidrs               = [for i in range(10, 255, 10) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs              = [for i in range(11, 255, 10) : cidrsubnet(local.vpc_cidr, 8, i)]
  service_name               = var.endpoint["s3"]
  service_type               = var.endpoint["service_gateway"]
  db_subnet_group            = true
  network_interface_id       = module.ec2.network_interface_id

}

module "rds" {
  source                  = "./modules/rds"
  db_storage              = 20
  db_engine_version       = var.db_engine_version
  db_instance_class       = var.db_instance_type[0]
  engine                  = var.rds_engine_type
  dbname                  = var.dbname
  dbuser                  = var.dbuser
  dbpassword              = var.dbpassword
  db_identifier           = var.identifier
  skip_db_snapshot        = var.skip_final_snapshot
  db_subnet_group_name    = module.vpc.db_subnet_group_name[0]
  vpc_security_group_ids  = module.vpc.db_security_group
  backup_retention_period = 7
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  deletion_protection     = false
}

module "s3" {
  source               = "./modules/s3"
  static_website_files = "./modules/files/S3_Static_Website"
  domain_name          = var.domain_name
  cname                = var.cname

}

module "ec2" {
  source         = "./modules/ec2"
  natinstance_sg = module.vpc.natinstance_sg
  public_subnets = module.vpc.public_subnets[0]
  instance_type  = var.instance_type[0]
  key_name       = var.key_name
}

module "iam" {
  source = "./modules/iam"
}

module "launch_template" {
  source               = "./modules/launch_template"
  instance_type        = var.instance_type[0]
  key_name             = var.key_name
  launch_template_sg   = module.vpc.launch_template_sg
  iam_instance_profile = module.iam.aws_capstone_ec2_s3_full_access
  user_data_path       = "${path.root}/modules/files/userdata.sh"
  dbname               = var.dbname
  dbuser               = var.dbuser
  dbpassword           = var.dbpassword
  db_address           = module.rds.db_address
  bucket_name          = module.s3.blog_bucket_name
  depends_on           = [module.rds.db_address, module.s3.blog_bucket_name]

}

module "elb-asg" {
  source                         = "./modules/elb-asg"
  alb_sg                         = module.vpc.alb_sg
  public_subnets                 = module.vpc.public_subnets
  private_subnets                = module.vpc.private_subnets
  tg_port                        = 80
  tg_protocol                    = "HTTP"
  vpc_id                         = module.vpc.vpc_id
  lb_healthy_threshold           = 2
  lb_unhealthy_threshold         = 2
  lb_timeout                     = 5
  lb_interval                    = 30
  launch_template_id             = module.launch_template.launch_template_id
  launch_template_latest_version = module.launch_template.launch_template_latest_version
  certificate_arn_elb            = module.acm.acm_arn

}

module "cloudfront" {
  source                   = "./modules/cloudfront"
  domain_name              = module.elb-asg.lb_endpoint
  origin_id                = var.origin_id
  enabled                  = var.distribution_enabled
  aliases                  = [join("", ["${var.cname}.", "${var.domain_name}"])]
  origin_protocol_policy   = var.origin_protocol_policy
  http_port                = var.origin_http_port
  https_port               = var.origin_https_port
  origin_keepalive_timeout = 5
  origin_ssl_protocols     = var.origin_ssl_protocols
  viewer_protocol_policy   = var.viewer_protocol_policy
  allowed_methods          = var.allowed_methods
  cached_methods           = var.cached_methods
  headers                  = var.forward_headers
  acm_certificate_arn      = module.acm.acm_arn
  ssl_support_method       = var.ssl_support_method
  minimum_protocol_version = var.viewer_minimum_protocol_version
  restriction_type         = var.geo_restriction_type
  compress                 = var.compress
  cookies_forward          = var.forward_cookies
  query_string             = var.forward_query_string

}

module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
  zone_id     = var.zone_id
}

module "route53" {
  source      = "./modules/route53"
  fqdn        = module.cloudfront.cloudfront_domain_name
  zone_id     = module.cloudfront.cloudfront_hosted_zone_id
  alias_s3    = module.s3.s3_website_endpoint
  zone_id_s3  = module.s3.s3_hosted_zone_id
  domain_name = var.domain_name
  cname       = var.cname

}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "lambda" {
  source              = "./modules/lambda"
  iam_role_for_lambda = module.iam.iam_role_for_lambda
  output_path         = "./modules/files/lambda_function.zip"
  dynamodb_table_name = module.dynamodb.dynamodb_table_name
  source_arn          = module.s3.blog_bucket_arn
  bucket_name         = module.s3.blog_bucket_name

}