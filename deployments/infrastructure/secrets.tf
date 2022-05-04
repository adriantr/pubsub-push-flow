resource "google_secret_manager_secret" "mailgun" {
  secret_id = "mailgun"
  replication {
    user_managed {
      replicas {
        location = local.region
      }
    }
  }

  depends_on = [
    google_project_service.main
  ]
}

resource "google_secret_manager_secret_iam_member" "notifier" {
  secret_id = google_secret_manager_secret.mailgun.secret_id
  member = "serviceAccount:${google_service_account.notifier.email}"
  role = "roles/secretmanager.secretAccessor"
}
