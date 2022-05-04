resource "google_storage_bucket_iam_member" "ordinary_writer" {
  bucket = google_storage_bucket.processed_ok.id
  role = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.ordinary_processor.email}"
}

resource "google_storage_bucket_iam_member" "dlq_writer" {
  bucket = google_storage_bucket.processed_error.id
  role = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.dlq_processor.email}"
}
