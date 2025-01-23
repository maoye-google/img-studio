resource "google_compute_global_address" "ip_address" {
  name = "external-ip"
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443" # You can add 443 if you manage TLS on the LB
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.ip_address.id
}

resource "google_compute_target_https_proxy" "default" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.default.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.id
  ]
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "ssl-certificate"
  type = "MANAGED"

  managed {
    domains = [var.customer_domain, "www.${var.customer_domain}"] # Replace with your domain name(s)
  }
}

resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_compute_backend_service.default.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.default.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.default.id
    }
  }
}

resource "google_compute_backend_service" "default" {
  name                  = "cloud-run-backend"
  port_name             = "http"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group           = google_compute_region_network_endpoint_group.cloud_run_neg.id
    balancing_mode  = "RATE" # Or UTILIZATION
    max_rate_per_endpoint = 10 # Adjust as needed.  Not relevant if using UTILIZATION balancing mode
  }

  # Using NEG as backend means no longer need to define health check explicitly
  # health_checks = [google_compute_health_check.http.id]
}

resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = "cloud-run-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region # Replace with your Cloud Run region
  cloud_run {
    service = google_cloud_run_v2_service.img_studio_service.name
  }
}

output "load_balancer_external_ip" {
  value = google_compute_global_forwarding_rule.default.ip_address
}