output "static_website_url" {
  value       = join("", ["https://", "${azurerm_storage_account.blog_storage.primary_web_host}"])
  description = "static web site URL from storage account"
}

output "static_website_cdn_endpoint_url" {
  value       = join("", ["https://", "${azurerm_cdn_endpoint.cdn_blog.name}.", "azureedge.net"])
  description = "CDN endpoint URL for Static website"
}

output "customdomainname" {
  value = join("", ["https://", "cat.${var.domain}"])
}