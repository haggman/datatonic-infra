module "bigquery" {
  source = "terraform-google-modules/bigquery/google"

  dataset_id   = "datatonic_pipeline"
  dataset_name = "datatonic_pipeline"
  description  = "Contains the tables for the case study pipeline"
  project_id   = var.project_id
  location     = var.gcp_region

  tables = [
    {
      table_id = "projects_staging",
      schema   = file("projects_staging_schema.json"),
      time_partitioning = {
        type                     = "DAY",
        field                    = "updated_at",
        require_partition_filter = false,
        expiration_ms            = null,
      },
      expiration_time    = null,
      range_partitioning = null,
      clustering         = ["id"],
      labels             = {}
    },
    {
      table_id = "tasks_staging",
      schema   = file("tasks_staging_schema.json"),
      time_partitioning = {
        type                     = "DAY",
        field                    = "updated_at",
        require_partition_filter = false,
        expiration_ms            = null,
      },
      expiration_time    = null,
      range_partitioning = null,
      clustering         = ["id"],
      labels             = {}
    },
  ]
}

//Transfer job for the projects.json
resource "google_bigquery_data_transfer_config" "load_projects" {
  project                = var.project_id
  display_name           = "project-loader"
  location               = var.gcp_region
  data_source_id         = "google_cloud_storage"
  schedule               = ""
  schedule_options {
    disable_auto_scheduling = true
  }
  destination_dataset_id = "datatonic_pipeline"
  params = {
    destination_table_name_template = "projects_staging"
    data_path_template              = "gs://bkt-pipeline-staging-f5399bba/projects.json"
    file_format                     = "JSON"
    write_disposition                = "MIRROR"
  }
}