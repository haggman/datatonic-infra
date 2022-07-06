//Enable project services/APIs
locals {
  apis_to_enable = toset([  
      //setup general APIs  
      "bigquery.googleapis.com",
      "bigquerymigration.googleapis.com",
      "bigquerystorage.googleapis.com",
      "cloudapis.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "cloudtrace.googleapis.com",
      "iam.googleapis.com",
      "iamcredentials.googleapis.com",
      "logging.googleapis.com",
      "monitoring.googleapis.com",
      "servicemanagement.googleapis.com",
      "serviceusage.googleapis.com",
      "storage-api.googleapis.com",
      "storage-component.googleapis.com",
      "storage.googleapis.com",
      "sts.googleapis.com",
      //Add compute for networking, VMs, etc.
      "compute.googleapis.com",
      //Cloud Composer
      "composer.googleapis.com",
      "sqladmin.googleapis.com"
    ])
}
resource "google_project_service" "enable_apis" {
  for_each = local.apis_to_enable
  project = var.project_id
  service = each.value

  disable_dependent_services = true
}