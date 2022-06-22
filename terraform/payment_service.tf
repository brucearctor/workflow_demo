resource "google_service_account" "account_for_payment" {
  provider     = google-beta
  account_id   = "payment-service-account"
  display_name = "Test Service Account"
}

data "archive_file" "payment_service_source" {
  type        = "zip"
  source_dir  = "../payment_service/"
  output_path = "/tmp/payment_service_function.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "payment_service_zip" {
  source       = data.archive_file.payment_service_source.output_path
  content_type = "application/zip"

  # not sure whether I'd want to use a different bucket for each function
  # won't worry about it for now
  name   = "src-${data.archive_file.payment_service_source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name

  depends_on = [
    google_storage_bucket.function_bucket,
    data.archive_file.payment_service_source
  ]
}



resource "google_cloudfunctions2_function" "payment_service" {
  provider    = google-beta
  name        = "payment-service"
  location    = "us-central1"
  description = "charging the card"

  build_config {
    runtime     = "go116"
    entry_point = "ChargeCard"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.payment_service_zip.name
      }
    }
  }

  service_config {
    max_instance_count    = 1
    available_memory      = "128Mi"
    timeout_seconds       = 30
    service_account_email = google_service_account.account_for_payment.email
  }

  # should auto-infer, but doesn't hurt much to have
  depends_on = [
    google_service_account.account_for_payment,
    google_storage_bucket.function_bucket,
    google_storage_bucket_object.payment_service_zip
  ]
}