terraform {
  required_version = ">= 1.3.7"
  required_providers {
    aws = {
      version = ">= 5.0.0"
    }
    sysdig = {
      source = "sysdiglabs/sysdig"
      version = ">= 1.36.0"
    }
  }
}