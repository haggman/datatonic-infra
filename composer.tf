# //Create the Composer instance
# resource "google_composer_environment" "pipeline_composer_instance" {
#   name   = "pipeline-composer"
#   region = var.gcp_region

#   config {
#     node_config {
#       service_account = google_service_account.composer_sa.email
#       network         = module.vpc.network_id
#       subnetwork      = module.vpc.subnets_ids[0]
#       //Make cluster VPC native (to support private IPs)
#       ip_allocation_policy {
#         use_ip_aliases = true
#       }
#     }

#     //Set cluster to use private IPs
#     private_environment_config {
#       enable_private_endpoint = true
#     }
#   }
# }
