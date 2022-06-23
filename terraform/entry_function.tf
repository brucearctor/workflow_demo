resource "google_service_account" "account" {
  provider     = google-beta
  account_id   = "test-service-account"
  display_name = "Test Service Account"
}

data "archive_file" "starting_point_source" {
  type        = "zip"
  source_dir  = "../starting_point/"
  output_path = "/tmp/starting_point_function.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.starting_point_source.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "src-${data.archive_file.starting_point_source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name

  depends_on = [
    google_storage_bucket.function_bucket,
    data.archive_file.starting_point_source
  ]
}

resource "google_cloudfunctions2_function" "starting-point" {
  provider    = google-beta
  name        = "starting-point"
  location    = "us-central1"
  description = "a new function"

  build_config {
    runtime     = "python39"
    entry_point = "starting_point"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.zip.name
      }
    }
  }

  service_config {
    max_instance_count    = 1
    available_memory      = "128Mi"
    timeout_seconds       = 30
    service_account_email = google_service_account.account.email
    environment_variables = {
      GCP_PROJECT     = var.project
      FUNCTION_REGION = var.region
      WORKFLOW_NAME   = google_workflows_workflow.workflow.name
    }
  }

  depends_on = [
    google_service_account.account,
    google_storage_bucket.function_bucket,
    google_storage_bucket_object.zip
  ]
}
