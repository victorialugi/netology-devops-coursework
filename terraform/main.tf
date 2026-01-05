data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# VPC сеть
resource "yandex_vpc_network" "coursework" {
  name = "coursework-net"
}

# Подсети
resource "yandex_vpc_subnet" "public-a" {
  name           = "public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.coursework.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private-a" {
  name           = "private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.coursework.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_subnet" "private-b" {
  name           = "private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.coursework.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

# Security Groups
resource "yandex_vpc_security_group" "sg-bastion" {
  name       = "sg-bastion"
  network_id = yandex_vpc_network.coursework.id

  ingress {
    protocol       = "TCP"
    description    = "SSH из интернета (временно)"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "sg-private" {
  name       = "sg-private"
  network_id = yandex_vpc_network.coursework.id

  ingress {
    protocol          = "TCP"
    description       = "SSH только с bastion"
    port              = 22
    security_group_id = yandex_vpc_security_group.sg-bastion.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion host (в публичной подсети public-a)
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
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
    subnet_id          = yandex_vpc_subnet.public-a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg-bastion.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yml", {
      ssh_public_key = var.ssh_public_key
    })
  }
}
