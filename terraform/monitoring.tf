# Security Group для Prometheus
resource "yandex_vpc_security_group" "sg-prometheus" {
  name        = "sg-prometheus"
  description = "Порт 9090 только из приватной сети"
  network_id  = yandex_vpc_network.coursework.id

  ingress {
    protocol       = "TCP"
    description    = "Prometheus от Grafana и других"
    port           = 9090
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH от bastion"
    port              = 22
    security_group_id = yandex_vpc_security_group.sg-private.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Grafana
resource "yandex_vpc_security_group" "sg-grafana" {
  name        = "sg-grafana"
  description = "Порт 3000 из интернета"
  network_id  = yandex_vpc_network.coursework.id

ingress {
    protocol       = "TCP"
    description    = "SSH из интернета (временно для Ansible)"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Grafana из интернета"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH от bastion"
    port              = 22
    security_group_id = yandex_vpc_security_group.sg-private.id
  }

ingress {
    protocol          = "TCP"
    description       = "SSH от bastion"
    port              = 22
    security_group_id = yandex_vpc_security_group.sg-private.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ВМ Prometheus
resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 4
    memory        = 8
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 30
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-a.id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.sg-private.id,
      yandex_vpc_security_group.sg-prometheus.id
    ]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yml", {
      ssh_public_key = var.ssh_public_key
    })
  }
}

# ВМ Grafana
resource "yandex_compute_instance" "grafana" {
  name        = "grafana"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-a.id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.sg-private.id,
      yandex_vpc_security_group.sg-grafana.id
    ]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yml", {
      ssh_public_key = var.ssh_public_key
    })
  }
}
