//Build a staging bucket


module "gcs_buckets" {
  source  = "terraform-google-modules/cloud-storage/google"
  project_id  = var.project_id
  names = ["data_staging"]
  prefix = "bkt"
  location = var.gcp_region
  randomize_suffix = true

  set_admin_roles = true
  admins = ["serviceAccount:${google_service_account.run_sa.email}"]

}