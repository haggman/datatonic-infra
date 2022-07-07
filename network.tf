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
      subnet_ip     = "10.0.0.0/20"
      subnet_region = var.gcp_region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
        sb-core-london = [
            {
                range_name    = "composer-cluster-pods"
                ip_cidr_range = "10.32.0.0/14"
            },
            {
                range_name    = "composer-cluster-services"
                ip_cidr_range = "10.36.0.0/20"
            },
        ]
    }

  # firewall_rules = [
  #     //Firewalls for Composer
  #     {
  #     name                    = "allow-ssh-ingress"
  #     description             = null
  #     direction               = "INGRESS"
  #     priority                = null
  #     ranges                  = ["0.0.0.0/0"]
  #     source_tags             = null
  #     source_service_accounts = null
  #     target_tags             = null
  #     target_service_accounts = null
  #     allow = [{
  #       protocol = "tcp"
  #       ports    = ["22"]
  #     }]
  #     deny = []
  #     log_config = {
  #       metadata = "INCLUDE_ALL_METADATA"
  #     }
  #   }
  # ]
}