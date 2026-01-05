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
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.sg-private.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(\"~/.ssh/id_ed25519.pub\")}"
    user-data = <<-EOT
      #cloud-config
      package_update: true
      packages:
        - nginx
      runcmd:
        - echo "<h1>Hello from web1 (zone a)</h1><p>Server: $(hostname)</p>" > /var/www/html/index.nginx-debian.html
        - systemctl enable nginx
        - systemctl restart nginx
      EOT
  }
}

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
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.sg-private.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(\"~/.ssh/id_ed25519.pub\")}"
    user-data = <<-EOT
      #cloud-config
      package_update: true
      packages:
        - nginx
      runcmd:
        - echo "<h1>Hello from web2 (zone b)</h1><p>Server: $(hostname)</p>" > /var/www/html/index.nginx-debian.html
        - systemctl enable nginx
        - systemctl restart nginx
      EOT
  }
}
