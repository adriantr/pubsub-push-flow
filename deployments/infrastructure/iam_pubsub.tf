resource "google_pubsub_topic_iam_member" "dlq_publisher" {
  topic = google_pubsub_topic.deadletter.id

  member = "serviceAccount:${google_project_service_identity.pubsub.email}"
  role   = "roles/pubsub.publisher"
}

resource "google_pubsub_subscription_iam_member" "ordinary_service_subscriber" {
  subscription = google_pubsub_subscription.ordinary.id
  member       = "serviceAccount:${google_project_service_identity.pubsub.email}"
  role         = "roles/pubsub.subscriber"
}

resource "google_pubsub_topic_iam_member" "ordinary_publisher" {
  topic  = google_pubsub_topic.ordinary.id
  member = "serviceAccount:${google_service_account.publisher.email}"
  role   = "roles/pubsub.publisher"
}

resource "google_pubsub_topic_iam_member" "gs_publisher" {
  topic  = google_pubsub_topic.gs_notifications.id
  member = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
  role   = "roles/pubsub.publisher"
}
