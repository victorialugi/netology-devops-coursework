output "bastion_public_ip" {
  value       = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
  description = "Публичный IP bastion-хоста для подключения по SSH"
}

output "web1_private_ip" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}

output "web2_private_ip" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}
