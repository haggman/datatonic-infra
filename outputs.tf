output "tf_state_bucket_name" {
  value = google_storage_bucket.tf_state_bucket.name
}

output "test_bucket_name" {
  value = google_storage_bucket.test_bucket.name
}