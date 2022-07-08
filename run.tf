//Create the SA for API Access
resource "google_service_account" "forecast_accessor_sa" {
  account_id   = "forecast-accessor"
  display_name = "Can access Forecast data"
  project      = var.project_id
}



//Create the SA for Cloud Run to use
resource "google_service_account" "run_sa" {
  account_id   = "sa-run-data-loader"
  display_name = "Cloud Run Data Loader"
  project      = var.project_id
}

//Set the permissions on the Cloud Run SA

locals {
  roles_for_run_sa = toset([
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
    "roles/storage.admin"
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