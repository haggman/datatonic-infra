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
    }
  }
}
