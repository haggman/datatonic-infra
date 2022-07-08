//Create the SA for composer to use
resource "google_service_account" "composer_sa" {
  account_id   = "sa-pipeline-composer"
  display_name = "Composer pipeline's SA"
  project      = var.project_id
}

//Set the permissions on the composer SA

locals {
  roles_for_sa = toset([
    "roles/composer.worker"
  ])
}
resource "google_project_iam_member" "composer_sa_roles" {
  for_each = local.roles_for_sa
  project  = var.project_id
  role     = each.value
  member = format("serviceAccount:%s",
  google_service_account.composer_sa.email)
}

//Create the Composer instance
resource "google_composer_environment" "pipeline_composer_instance" {
  name   = "pipeline-composer"
  region = var.gcp_region

  config {
    node_config {
      service_account = google_service_account.composer_sa.email
      network         = module.vpc.network_id
      subnetwork      = module.vpc.subnets_ids[0]
      //Make cluster VPC native (to support private IPs)
      ip_allocation_policy {
        use_ip_aliases                = true
        cluster_secondary_range_name  = "composer-cluster-pods"
        services_secondary_range_name = "composer-cluster-services"
      }
    }

    //Set cluster to use private IPs
    private_environment_config {
      enable_private_endpoint = true
      master_ipv4_cidr_block  = var.composer_master_cidr
    }
  }
}


//Create the SA that deploys to Composer
resource "google_service_account" "composer_deployer_sa" {
  account_id   = "sa-composer-deployer"
  display_name = "Composer Deployer"
  project      = var.project_id
}

//Set the permissions on the composer deployer SA

locals {
  roles_for_deployer_sa = toset([
    "roles/storage.objectAdmin"
  ])
}
resource "google_project_iam_member" "composer_deployer_sa_roles" {
  for_each = local.roles_for_deployer_sa
  project  = var.project_id
  role     = each.value
  member = format("serviceAccount:%s",
  google_service_account.composer_deployer_sa.email)
}
