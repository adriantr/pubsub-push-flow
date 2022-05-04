resource "google_pubsub_topic" "ordinary" {
  name = "ordinary"
}

resource "google_pubsub_topic" "deadletter" {
  name = "deadletter"
}

resource "google_pubsub_topic" "gs_notifications" {
  name = "gs-notifications"
}

resource "google_pubsub_subscription" "ordinary" {
  name  = local.ordinary_subscription_name
  topic = google_pubsub_topic.ordinary.id

  push_config {
    push_endpoint = google_cloud_run_service.ordinary_processor.status[0].url
    oidc_token {
      service_account_email = google_service_account.ordinary_processor.email
    }
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.deadletter.id
    max_delivery_attempts = 5
  }
  
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}

resource "google_pubsub_subscription" "dlq_saver" {
  name  = "deadletter-gs-saver"
  topic = google_pubsub_topic.deadletter.id

  push_config {
    push_endpoint = google_cloud_run_service.dlq_processor.status[0].url
    oidc_token {
      service_account_email = google_service_account.dlq_processor.email
    }
  }
}

resource "google_pubsub_subscription" "notifier" {
  name = "notifier"
  topic = google_pubsub_topic.gs_notifications.id

  push_config {
    push_endpoint = google_cloud_run_service.notifier.status[0].url
    oidc_token {
      service_account_email = google_service_account.notifier.email
    }
  }
}
