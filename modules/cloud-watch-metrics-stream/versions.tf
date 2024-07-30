terraform {
  required_version = ">= 1.0.2"
  required_providers {
    aws = {
      version = ">= 4.0.0"
    }
    sysdig = {
      source = "sysdiglabs/sysdig"
      version = ">= 1.36.0"
    }
  }
}