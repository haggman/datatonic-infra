/*
    Note: my project came out of the box with the default
    network in place. I manually removed it, so I could
    build the custom one.
*/

//build the network, the Google blueprint makes it easier
module "vpc" {
  source = "terraform-google-modules/network/google"

  project_id   = var.project_id
  network_name = "vpc-core"

  subnets = [
    {
      subnet_name   = "sb-core-london"
      subnet_ip     = var.london_subnet_cidr
      subnet_region = var.gcp_region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
        sb-core-london = [
            {
                range_name    = "composer-cluster-pods"
                ip_cidr_range = var.composer_pod_cidr
            },
            {
                range_name    = "composer-cluster-services"
                ip_cidr_range = var.composer_service_cidr
            },
        ]
    }

  firewall_rules = [
      //Firewalls for Composer
    {
      name                    = "fw-core-1000-i-a-node-node-tcp-all"
      description             = null
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = [var.london_subnet_cidr]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = [google_service_account.composer_sa.email]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
      deny = []
    },
    {
      name                    = "fw-core-1000-i-a-master-node-tcp-all"
      description             = null
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = [var.composer_master_cidr]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = [google_service_account.composer_sa.email]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
      deny = []
    },
    {
      name                    = "fw-core-1000-i-a-service-node-tcp-all"
      description             = null
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = [var.composer_service_cidr]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = [google_service_account.composer_sa.email]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
      deny = []
    },
    {
      name                    = "fw-core-1000-i-a-health-check-node-tcp-80-443"
      description             = null
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["130.211.0.0/22", "35.191.0.0/16"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = [google_service_account.composer_sa.email]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
      deny = []
    }
  ]
}