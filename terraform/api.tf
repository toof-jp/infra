locals {
  google_apis = [
    "monitoring.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtrace.googleapis.com",
    "logging.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}

resource "google_project_service" "enabled" {
  for_each = toset(local.google_apis)
  service  = each.key
}

moved {
  from = google_project_service.monitoring
  to   = google_project_service.enabled["monitoring.googleapis.com"]
}

moved {
  from = google_project_service.serviceusage
  to   = google_project_service.enabled["serviceusage.googleapis.com"]
}

moved {
  from = google_project_service.cloudresourcemanager
  to   = google_project_service.enabled["cloudresourcemanager.googleapis.com"]
}

moved {
  from = google_project_service.cloudtrace
  to   = google_project_service.enabled["cloudtrace.googleapis.com"]
}

moved {
  from = google_project_service.logging
  to   = google_project_service.enabled["logging.googleapis.com"]
}

moved {
  from = google_project_service.iam
  to   = google_project_service.enabled["iam.googleapis.com"]
}

moved {
  from = google_project_service.iamcredentials
  to   = google_project_service.enabled["iamcredentials.googleapis.com"]
}

moved {
  from = google_project_service.sts
  to   = google_project_service.enabled["sts.googleapis.com"]
}

moved {
  from = google_project_service.cloudfunctions
  to   = google_project_service.enabled["cloudfunctions.googleapis.com"]
}

moved {
  from = google_project_service.cloudbuild
  to   = google_project_service.enabled["cloudbuild.googleapis.com"]
}

moved {
  from = google_project_service.artifactregistry
  to   = google_project_service.enabled["artifactregistry.googleapis.com"]
}

moved {
  from = google_project_service.run
  to   = google_project_service.enabled["run.googleapis.com"]
}

moved {
  from = google_project_service.eventarc
  to   = google_project_service.enabled["eventarc.googleapis.com"]
}

moved {
  from = google_project_service.secretmanager
  to   = google_project_service.enabled["secretmanager.googleapis.com"]
}
