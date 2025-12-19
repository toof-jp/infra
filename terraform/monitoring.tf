resource "google_monitoring_uptime_check_config" "healthcheck_http" {
  display_name = "healthcheck.toof.jp-http"
  timeout      = "10s"
  period       = "60s"

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = google_project.toof_infra.project_id
      host       = "healthcheck.toof.jp"
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

resource "google_monitoring_notification_channel" "discord_webhook" {
  display_name = "Discord Webhook Notifications"
  type         = "webhook_tokenauth"
  description  = "Sends Cloud Monitoring alerts to the Discord #notification channel."

  labels = {
    url = discord_webhook.webhook.url
  }
}

resource "google_monitoring_alert_policy" "healthcheck_http_down" {
  display_name = "healthcheck.toof.jp HTTP down"
  combiner     = "OR"
  enabled      = true

  documentation {
    content   = "healthcheck.toof.jp uptime check is failing."
    mime_type = "text/markdown"
  }

  notification_channels = [
    google_monitoring_notification_channel.discord_webhook.id,
  ]

  conditions {
    display_name = "Uptime check failure"

    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND metric.label.\"check_id\"=\"${google_monitoring_uptime_check_config.healthcheck_http.uptime_check_id}\""
      comparison      = "COMPARISON_LT"
      threshold_value = 1
      duration        = "120s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }
}
