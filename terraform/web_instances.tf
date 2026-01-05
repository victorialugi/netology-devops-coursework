# Security Group для веб-серверов
resource "yandex_vpc_security_group" "sg-web" {
  name        = "sg-web"
  description = "Разрешает HTTP от ALB и health checks"
  network_id  = yandex_vpc_network.coursework.id

  ingress {
    protocol       = "TCP"
    description    = "Health checks от Yandex ALB"
    port           = 80
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.239.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH только с bastion"
    port           = 22
    security_group_id = yandex_vpc_security_group.sg-private.id
  }

  egress {
    protocol       = "ANY"
    description    = "Исходящий трафик"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Веб-сервер 1 (зона a)
resource "yandex_compute_instance" "web1" {
  name        = "web1"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-a.id
    nat                = false
    security_group_ids = [
      yandex_vpc_security_group.sg-private.id,
      yandex_vpc_security_group.sg-web.id
    ]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yml", {
      ssh_public_key = var.ssh_public_key
    })
  }
}

# Веб-сервер 2 (зона b)
resource "yandex_compute_instance" "web2" {
  name        = "web2"
  zone        = "ru-central1-b"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-b.id
    nat                = false
    security_group_ids = [
      yandex_vpc_security_group.sg-private.id,
      yandex_vpc_security_group.sg-web.id
    ]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yml", {
      ssh_public_key = var.ssh_public_key
    })
  }
}
