terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      version = ">= 5.70.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 1.37.1"
    }
  }
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
}