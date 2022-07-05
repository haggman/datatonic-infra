provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

/*
    This section would be commented out initally. After building 
    the initial infra, drop in the bucket name and redo
    terraform init
    to copy the state file into the bucket.
*/
terraform {
  backend "gcs" {
    bucket = "bkt-tfstate-a9fe4b60314bf1c2"
    prefix = "terraform/state"
  }
}


//build the tf_state bucket
resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_storage_bucket" "tf_state_bucket" {
  name          = "bkt-tfstate-${random_id.instance_id.hex}"
  force_destroy = false
  location      = var.gcp_region
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }

}

resource "google_storage_bucket" "test_bucket" {
  name          = "bkt-test-${random_id.instance_id.hex}"
  force_destroy = true
  location      = var.gcp_region
  storage_class = "STANDARD"
}