//Build a staging bucket

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "pipeline_staging_bucket" {
  name          = "bkt-pipeline-staging-${random_id.bucket_suffix.hex}"
  force_destroy = false
  location      = var.gcp_region
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }

}