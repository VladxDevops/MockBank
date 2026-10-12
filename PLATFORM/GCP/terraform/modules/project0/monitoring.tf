# ==============================================================================
# MONITORING.TF - Project 0: Centralized Platform Observability & Alerting
# Strategy Reference: Documentation/internal/MONITORING.md
# Agent Protocols:    Documentation/internal/AGENTS.md & terraform/AGENTS.md
# Classification:     INTERNAL USE ONLY
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Log-Based Metrics (Cloud Logging)
# ------------------------------------------------------------------------------

# --- Foundation & Security Metrics (Section 6 & Global) ---

# Audit & Security bot metric: Scans logs for potential unmasked email addresses or card/account numbers
resource "google_logging_metric" "pii_leakage_detected" {
  project     = var.compute_project_id
  name        = "platform-pii-leakage"
  description = "Security bot metric: detects potential unmasked email or account numbers in application logs"
  filter      = "resource.type=\"cloud_run_revision\" AND (textPayload=~\"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\" OR textPayload=~\"\\b[0-9]{4}[ -]?[0-9]{4}[ -]?[0-9]{4}[ -]?[0-9]{4}\\b\")"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# Audit & Security bot metric: Tracks non-declarative configuration actions in GCP audit logs
resource "google_logging_metric" "unauthorized_console_changes" {
  project     = var.compute_project_id
  name        = "platform-unauthorized-console-changes"
  description = "Tracks manual non-declarative configuration changes made via GCP Console"
  filter      = "protoPayload.@type=\"type.googleapis.com/google.cloud.audit.AuditLog\" AND protoPayload.authenticationInfo.principalEmail!~\"gserviceaccount.com$\" AND protoPayload.methodName=~\"(create|update|delete|patch)\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# --- Project 1: Identity Service (Keycloak) Log Metrics (Section 2) ---

# Tracks login errors (indicates potential brute-force or credential stuffing)
resource "google_logging_metric" "keycloak_login_errors" {
  project     = var.compute_project_id
  name        = "keycloak-login-errors"
  description = "Tracks Keycloak authentication failures (type=LOGIN_ERROR)"
  filter      = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.project1_service_name}\" AND (textPayload:\"type=LOGIN_ERROR\" OR jsonPayload.message:\"type=LOGIN_ERROR\")"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# Tracks Cloud SQL connection pool acquisition timeouts
resource "google_logging_metric" "keycloak_db_acquisition_timeouts" {
  project     = var.compute_project_id
  name        = "keycloak-db-acquisition-timeouts"
  description = "Tracks Cloud SQL connection pool saturation and acquisition timeouts in Keycloak"
  filter      = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.project1_service_name}\" AND (textPayload:\"Acquisition timeout\" OR jsonPayload.message:\"Acquisition timeout\")"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}


# --- Project 2: Transaction Service Log Metrics (Section 3) ---

# Tracks failures to write audit log entries to MongoDB Atlas (Audit Gap detector - Severity 1)
resource "google_logging_metric" "project2_audit_log_errors" {
  project     = var.compute_project_id
  name        = "project2-audit-log-errors"
  description = "Tracks audit log persistence errors to MongoDB Atlas in Transaction Service"
  filter      = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.transaction_service_name}\" AND (severity>=ERROR OR textPayload:\"Error saving audit log\" OR jsonPayload.message:\"Error saving audit log\")"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "service"
      value_type  = "STRING"
      description = "The service generating the error"
    }
  }

  label_extractors = {
    "service" = "EXTRACT(resource.labels.service_name)"
  }
}

# Tracks step-up MFA challenges issued for transactions >= $10,000
resource "google_logging_metric" "project2_mfa_challenges_issued" {
  project     = var.compute_project_id
  name        = "project2-mfa-challenges-issued"
  description = "Tracks step-up MFA challenge issued events for transactions >= $10,000"
  filter      = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.transaction_service_name}\" AND (jsonPayload.steps.step=\"mfa_challenge_issued\" OR textPayload:\"mfa_challenge_issued\")"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# Tracks MFA verification timeout failures in transaction journey (Severity 2 indicator)
resource "google_logging_metric" "project2_mfa_timeouts" {
  project     = var.compute_project_id
  name        = "project2-mfa-timeouts"
  description = "Tracks MFA verification timeout failures in transaction journey"
  filter      = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.transaction_service_name}\" AND (jsonPayload.steps.error_code=\"TIMEOUT\" OR textPayload:\"TIMEOUT\")"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# ------------------------------------------------------------------------------
# 2. Alert Policies (Cloud Monitoring)
# ------------------------------------------------------------------------------

# --- Severity 1 (Critical) - Immediate Page (Section 5) ---

# Sev-1: Audit Gap Detection (Financial transactions occurring without immutable audit persistence)
resource "google_monitoring_alert_policy" "audit_gap_critical" {
  count        = var.enable_alerting ? 1 : 0
  project      = var.compute_project_id
  display_name = "[Sev-1] Project 2 Audit Gap / MongoDB Write Failure"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Audit Log Persistence Error Rate > 0"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.project2_audit_log_errors.name}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "## SEVERITY 1 (CRITICAL) - Audit Gap Detected\n\n**Service:** `${var.transaction_service_name}`\n**Impact:** Transaction audit logging to MongoDB Atlas failed. Under the Prime Directive (Security First), all financial transactions must have immutable audit trails.\n\n**Action Items:**\n1. Check MongoDB Atlas connectivity & cluster status.\n2. Inspect Cloud Run VPC connector egress health.\n3. Verify database credentials in Secret Manager."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "1800s" # 30 minutes
  }
}

# Sev-1: Keycloak Service Returning 5xx for > 1 minute
resource "google_monitoring_alert_policy" "keycloak_5xx_critical" {
  count        = var.enable_alerting ? 1 : 0
  project      = var.compute_project_id
  display_name = "[Sev-1] Keycloak Identity Service 5xx HTTP Errors"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Keycloak 5xx responses > 1 per minute"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.project1_service_name}\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = \"5xx\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.labels.service_name"]
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "## SEVERITY 1 (CRITICAL) - Keycloak Service 5xx Errors\n\n**Service:** `${var.project1_service_name}`\n**Impact:** Identity service returning 5xx errors for > 1 minute. Blocks authentication platform-wide.\n\n**Action Items:**\n1. Inspect Cloud SQL database availability & connection pool.\n2. Check Cloud Run revisions and container logs.\n3. Verify Secret Manager database secret access."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "1800s"
  }
}

# Sev-1: Transaction Service Cloud Run 5xx Errors
resource "google_monitoring_alert_policy" "transaction_5xx_critical" {
  count        = var.enable_alerting ? 1 : 0
  project      = var.compute_project_id
  display_name = "[Sev-1] Transaction Service 5xx HTTP Errors"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Transaction Service 5xx responses > 1 per minute"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.transaction_service_name}\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = \"5xx\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.labels.service_name"]
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "## SEVERITY 1 (CRITICAL) - Transaction Service 5xx Errors\n\n**Service:** `${var.transaction_service_name}`\n**Impact:** Financial transaction service failing requests.\n\n**Action Items:**\n1. Inspect Cloud Run container error logs.\n2. Check MongoDB Atlas connectivity and latency.\n3. Verify VPC connector status."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "1800s"
  }
}

# --- Severity 2 (Warning) - Ticket Created (Section 5) ---

# Sev-2: Increased MFA Timeout Rate (> 5% of challenges / threshold)
resource "google_monitoring_alert_policy" "mfa_timeouts_warning" {
  count        = var.enable_alerting ? 1 : 0
  project      = var.compute_project_id
  display_name = "[Sev-2] Elevated MFA Timeout Rate on Transactions"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "MFA Timeout Count > Threshold in 5m"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.project2_mfa_timeouts.name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.mfa_timeout_threshold

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "## SEVERITY 2 (WARNING) - High MFA Timeout Rate\n\n**Service:** `${var.transaction_service_name}`\n**Impact:** Elevated rate of user MFA verification timeouts on step-up auth ($10k+ transfers).\n\n**Action Items:**\n1. Run MongoDB diagnostic query from `PROJECT_DETAILS.md`:\n```javascript\ndb.journeys.find({\"steps.step\": \"mfa_verification\", \"steps.status\": \"failed\", \"steps.error_code\": \"TIMEOUT\"}).sort({timestamp: -1})\n```\n2. Verify upstream identity provider (Keycloak) response times."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "3600s"
  }
}

# Sev-2: Keycloak JDBC / Cloud SQL Connection Saturation
resource "google_monitoring_alert_policy" "keycloak_db_saturation_warning" {
  count        = var.enable_alerting ? 1 : 0
  project      = var.compute_project_id
  display_name = "[Sev-2] Keycloak DB Connection Acquisition Timeout"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "DB Acquisition Timeouts > 0 in 5m"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.keycloak_db_acquisition_timeouts.name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "## SEVERITY 2 (WARNING) - Cloud SQL Saturation in Keycloak\n\n**Service:** `${var.project1_service_name}`\n**Impact:** Keycloak is logging acquisition timeouts indicating Cloud SQL connection pool saturation (Max 20 connections for f1-micro).\n\n**Action Items:**\n1. Check active Cloud SQL connections.\n2. Review Quarkus DB connection pool configuration in Cloud Run environment."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "3600s"
  }
}

# Sev-2: High Cloud Run Request Latency (p95 > 1.5s)
resource "google_monitoring_alert_policy" "latency_p95_warning" {
  count        = var.enable_alerting ? 1 : 0
  project      = var.compute_project_id
  display_name = "[Sev-2] Cloud Run p95 Latency High (> ${var.latency_threshold_ms}ms)"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Cloud Run p95 latency > ${var.latency_threshold_ms}ms"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/request_latencies\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.latency_threshold_ms

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_95"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["resource.labels.service_name"]
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "## SEVERITY 2 (WARNING) - High Latency\n\n**Impact:** Cloud Run p95 request latency exceeds ${var.latency_threshold_ms}ms threshold.\n\n**Action Items:**\n1. Check backend database latency (Cloud SQL / MongoDB Atlas).\n2. Inspect container CPU/memory throttling."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "3600s"
  }
}

# Sev-2: Container Memory Saturation (> 80%)
resource "google_monitoring_alert_policy" "container_memory_warning" {
  count        = var.enable_alerting ? 1 : 0
  project      = var.compute_project_id
  display_name = "[Sev-2] Container Memory Utilization High (> 80%)"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Container Memory Utilization > 80%"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/container/memory/utilizations\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["resource.labels.service_name"]
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "## SEVERITY 2 (WARNING) - Container Memory Saturation\n\n**Impact:** Cloud Run container memory utilization exceeds 80%.\n\n**Action Items:**\n1. Check memory utilization metrics per service.\n2. Adjust memory limits or investigate heap memory allocation."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "3600s"
  }
}

# Sev-2: Container CPU Saturation (> 80%)
resource "google_monitoring_alert_policy" "container_cpu_warning" {
  count        = var.enable_alerting ? 1 : 0
  project      = var.compute_project_id
  display_name = "[Sev-2] Container CPU Utilization High (> 80%)"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Container CPU Utilization > 80%"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/container/cpu/utilizations\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["resource.labels.service_name"]
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "## SEVERITY 2 (WARNING) - Container CPU Saturation\n\n**Impact:** Cloud Run container CPU utilization exceeds 80%.\n\n**Action Items:**\n1. Review incoming request rate and concurrency settings.\n2. Scale container CPU allocation or max instances if appropriate."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "3600s"
  }
}

# ------------------------------------------------------------------------------
# 3. Central Platform Observability Dashboard (Cloud Monitoring)
# ------------------------------------------------------------------------------

resource "google_monitoring_dashboard" "platform_observability_dashboard" {
  project = var.compute_project_id
  dashboard_json = jsonencode({
    displayName = "Bank Platform Observability & Security Dashboard"
    gridLayout = {
      columns = "2"
      widgets = [
        {
          title = "Cloud Run Request Volume by Response Code Class"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["metric.label.response_code_class", "resource.label.service_name"]
                    }
                  }
                }
                plotType = "STACKED_BAR"
              }
            ]
          }
        },
        {
          title = "Cloud Run Latency Percentiles (p50, p95, p99)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_latencies\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_PERCENTILE_95"
                      crossSeriesReducer = "REDUCE_MEAN"
                      groupByFields      = ["resource.label.service_name"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "Project 2 Step-Up Auth: Challenges Issued vs Timeouts"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.project2_mfa_challenges_issued.name}\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
                plotType = "LINE"
              },
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.project2_mfa_timeouts.name}\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "Audit & Security Alerts: MongoDB Errors & Keycloak Login Failures"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.project2_audit_log_errors.name}\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
                plotType = "LINE"
              },
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.keycloak_login_errors.name}\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "Container CPU & Memory Utilization Across Services"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/container/cpu/utilizations\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MEAN"
                      groupByFields      = ["resource.label.service_name"]
                    }
                  }
                }
                plotType = "LINE"
              },
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/container/memory/utilizations\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MEAN"
                      groupByFields      = ["resource.label.service_name"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        }
      ]
    }
  })
}
