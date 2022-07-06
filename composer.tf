// Setup the permissions for the Composer SA
// auto created when the API is enabled
resource "google_project_iam_member" "composer_sa_role" {
  project  = var.project_id
  role     = "roles/composer.ServiceAgentV2Ext"
  member   = format("serviceAccount:service-%s@cloudcomposer-accounts.iam.gserviceaccount.com", var.project_number)
  depends_on = [ //make sure the composer API is enabled before configuring it's SA
    google_project_service.enable_apis
  ]
}

