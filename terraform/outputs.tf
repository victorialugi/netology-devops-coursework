output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "web1_private_ip" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}

output "web2_private_ip" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}

output "alb_public_ip" {
  description = "Публичный IP Application Load Balancer"
  value       = yandex_alb_load_balancer.web-alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "prometheus_private_ip" {
  value = yandex_compute_instance.prometheus.network_interface.0.ip_address
}

output "grafana_public_ip" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "elasticsearch_private_ip" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
