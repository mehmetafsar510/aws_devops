output "websiteurl" {
  value = "https://${aws_alb.app-lb.dns_name}"
}

output "phonebookdomainname" {
  value = join("", ["https://", "terraform.${var.domain_name}"])
}