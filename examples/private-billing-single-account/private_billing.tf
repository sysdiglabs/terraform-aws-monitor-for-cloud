terraform {
    required_providers {
        sysdig = {
            source  = "sysdiglabs/sysdig"
            version = "1.43"
        }
    }
}

module "private_billing" {
    source = "../../modules/private-billing"
}