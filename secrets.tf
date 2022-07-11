// Setup the secret for API access. Note: the secret's actual value will need to 
// be manually set. 

module "secret_manager_iam" {
  source  = "terraform-google-modules/iam/google//modules/secret_manager_iam"
  project = var.project_id
  secrets = ["forecast-api-secret"]
  mode = "additive"

  //going to let Cloud Run and Airflow access secrets, just in case
  //(since I'm not sure which will really need it for now)
  bindings = {
    "roles/secretmanager.secretAccessor" = [
      "serviceAccount:${google_service_account.composer_sa.email}",
      "serviceAccount:${google_service_account.run_sa.email}",
    ]
  }
}