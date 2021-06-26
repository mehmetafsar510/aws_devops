output "elb_dnsname" {
  value = module.elb-asg.elb_dnsname
}

output "cloudfront_dnsname" {
  value = module.cloudfront.cloudfront_dnsname
}

output "capstonedomainname" {
  value = module.acm.capstonedomainname
}