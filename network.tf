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
    }
  ]
}
