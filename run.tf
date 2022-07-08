//Create the SA for Cloud Run to use
resource "google_service_account" "run_sa" {
  account_id   = "forecast-accessor"
  display_name = "Can access Forecast data"
  project      = var.project_id
}

//Set the permissions on the Cloud Run SA

locals {
  roles_for_run_sa = toset([
    "roles/iam.serviceAccountUser"
  ])
}
resource "google_project_iam_member" "run_sa_roles" {
  for_each = local.roles_for_run_sa
  project  = var.project_id
  role     = each.value
  member = format("serviceAccount:%s",
  google_service_account.run_sa.email)
}

//Create the SA for Cloud Run deployer
resource "google_service_account" "run_deployer_sa" {
  account_id   = "sa-run-data-loader-deployer"
  display_name = "Can deploy the Cloud Run Data Loader"
  project      = var.project_id
}

//Set the permissions on the Cloud Run SA

locals {
  roles_for_run_deployer_sa = toset([
    "roles/run.admin",
    "roles/storage.admin", //Really only needed for first push (Creates initial GCR bucket)
    "roles/iam.serviceAccountUser"
  ])
}
resource "google_project_iam_member" "run_deployer_sa_roles" {
  for_each = local.roles_for_run_deployer_sa
  project  = var.project_id
  role     = each.value
  member = format("serviceAccount:%s",
  google_service_account.run_deployer_sa.email)
}

//Make sure the GCR bucket exists
resource "google_container_registry" "run_registry" {
  project  = var.project_id
  location = "EU" //doesn't support London only
}
//The created bucket's name is in:
//google_container_registry.run_registry.id

//Create Cloud Run's VPC Connector
# resource "google_vpc_access_connector" "connector" {
#   name          = "vpcconn"
#   region        = var.gcp_region
#   ip_cidr_range = var.composer_vpc_access_subnet
#   network       = module.vpc.network_id
# }