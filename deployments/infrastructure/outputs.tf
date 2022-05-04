output "publisher_url" {
  value = google_cloud_run_service.publisher.status[0].url
}
