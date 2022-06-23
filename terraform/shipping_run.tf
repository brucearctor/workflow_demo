resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = false
}

resource "google_cloud_run_service" "shipping_run_service" {
  name     = "shipping"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/shipping:latest"
      }
    }
  }

  depends_on = [google_project_service.run_api]
}