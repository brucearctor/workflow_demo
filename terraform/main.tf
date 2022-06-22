variable "project" {
  type    = string
  default = "affable-context-292903"
}

variable "region" {
  type    = string
  default = "us-central1"
}

## BACKEND - for now - is LOCAL
## THAT SHOULD BE SOMEWHERE LIKE 
## A GCS BUCKET OR OTHER LOCATION

provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}

resource "google_project_service" "functions" {
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "workflows" {
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "workflows_service_account" {
  account_id   = "sample-workflows-sa"
  display_name = "Sample Workflows Service Account"
}

resource "google_pubsub_topic" "example" {
  name = "example-topic"
}

resource "google_pubsub_subscription" "example" {
  name  = "example-subscription"
  topic = google_pubsub_topic.example.name

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20
}

resource "google_project_iam_binding" "project" {
  project = "affable-context-292903"
  # EDITOR IS TOO PERMISSIVE.  
  # SUGGEST TO LIMIT PERMISSIONS FURTHER
  role = "roles/editor"

  ##"serviceAccount:${google_service_account.workflows_service_account.account_id}@${var.project}.iam.gserviceaccount.com",
  members = [
    "serviceAccount:${google_service_account.workflows_service_account.email}",
    "serviceAccount:${google_service_account.account.email}"
  ]
  depends_on = [
    google_service_account.workflows_service_account,
    google_service_account.account
  ]
}

resource "google_workflows_workflow" "workflow" {
  name            = "first-workflow"
  region          = var.region
  description     = "A sample retail workflow"
  service_account = google_service_account.workflows_service_account.id
  # wanting the var to be something like:  google_cloudfunctions2_function.payment_service.uri
  # or google_cloudfunctions2_function.payment_service.service_config.uri
  # per tfstate, and
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function
  # #IGiveUp ... for now :-)
  source_contents = templatefile("workflow.yaml", { uri = "https://test.dev" })

  depends_on = [google_project_service.workflows]
}


