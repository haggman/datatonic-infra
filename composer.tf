//Create the SA for composer to use
resource "google_service_account" "composer_sa" {
  account_id   = "sa-pipeline-composer"
  display_name = "Composer pipeline's SA"
  project      = var.project_id
}

//Set the permissions on the composer SA

