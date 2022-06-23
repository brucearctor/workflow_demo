terraform {
  required_version = ">= 1.1"

  required_providers {
    google      = ">= 4.2"
    google-beta = ">= 4.2"
  }
}

variable "projectnumber" {
  type    = string
  default = "662116196692"
}

variable "project" {
  type    = string
  default = "new-project-354204"
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

resource "google_pubsub_topic" "pubsubtopic" {
  name = "pubsubtopic"
}

resource "google_pubsub_subscription" "example" {
  name  = "example-subscription"
  topic = google_pubsub_topic.pubsubtopic.name

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20
}

resource "google_project_iam_binding" "project" {
  project = var.project
  # EDITOR IS TOO PERMISSIVE.  
  # SUGGEST TO LIMIT PERMISSIONS FURTHER
  role = "roles/editor"

  # THIS IS TOO MUCH PERMISSION, BUT FOR DEMO [ not even 'test' environment am ok with it]
  members = [
    "serviceAccount:${google_service_account.workflows_service_account.email}",
    "serviceAccount:${google_service_account.account.email}",
    "serviceAccount:${var.projectnumber}@cloudbuild.gserviceaccount.com"
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
  source_contents = templatefile("workflow.yaml", {
    uri          = google_cloudfunctions2_function.payment_service.service_config[0].uri,
    shipping_url = google_cloud_run_service.shipping_run_service.status[0].url,
    project_id   = var.project,
    topic_name   = google_pubsub_topic.pubsubtopic.name
    }
  )

  depends_on = [google_project_service.workflows]
}


