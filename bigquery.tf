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
      schema   = file("input_staging_schema.json"),
      time_partitioning = {
        type  = "DAY",
        field = "start_date",
        require_partition_filter = false,
        expiration_ms            = null,
      },
      expiration_time = null,
      range_partitioning = null,
      clustering      = ["id"],
      labels = {}
    },
  ]
}
