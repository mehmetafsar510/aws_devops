output "acm_arn" {
    value = aws_acm_certificate_validation.cert_validation.certificate_arn 
}

output "capstonedomainname" {
    value = join("", ["https://", "capstone.${var.domain_name}"])
  
}