variable "sysdig_monitor_api_token" {
    description = "Sysdig Monitor API token for an admin user"
    type        = string
    sensitive   = true
}

variable "sysdig_monitor_url" {
    description = "Sysdig Monitor URL (e.g. https://us2.app.sysdig.com )"
    type        = string
}