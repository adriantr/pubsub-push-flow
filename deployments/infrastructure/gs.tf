#To make gs buckets unique
resource "random_string" "main" {
  length  = 5
  special = false
  upper   = false
}

resource "google_storage_bucket" "processed_ok" {
  name                        = "pubsub-ok-${random_string.main.result}"
  uniform_bucket_level_access = true
  location                    = local.region
}

resource "google_storage_bucket" "processed_error" {
  name                        = "pubsub-error-${random_string.main.result}"
  uniform_bucket_level_access = true
  location                    = local.region
}

resource "google_storage_notification" "error_notification" {
  bucket = google_storage_bucket.processed_error.name
  payload_format = "JSON_API_V1"
  topic = google_pubsub_topic.gs_notifications.id
  event_types = [ "OBJECT_FINALIZE" ]
}
