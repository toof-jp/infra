resource "google_monitoring_uptime_check_config" "healthcheck_http" {
  display_name = "healthcheck.toof.jp-http"
  timeout      = "10s"
  period       = "60s"

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = google_project.toof_infra.project_id
      host       = "healthcheck.toof.jp"
      region     = "global"
    }
  }

  http_check {
    path           = "/healthz"
    port           = 80
    request_method = "GET"
    use_ssl        = false
    validate_ssl   = false
    accepted_response_status_codes {
      status_value = 200
    }
  }

  selected_regions = [
    "USA",
    "EUROPE",
    "ASIA_PACIFIC",
  ]
}
