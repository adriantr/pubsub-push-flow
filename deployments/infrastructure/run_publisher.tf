resource "google_service_account" "publisher" {
  account_id = "publisher"
}

resource "google_cloud_run_service" "publisher" {
  name     = "publisher"
  location = "europe-north1"

  template {
    spec {
      service_account_name = google_service_account.publisher.email

      containers {
        image = "eu.gcr.io/${var.project_id}/message-publisher"

        ports {
          container_port = 8080
        }

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "TOPIC"
          value = google_pubsub_topic.ordinary.name
        }
      }
    }
  }

  depends_on = [
    google_project_service.main
  ]
}
