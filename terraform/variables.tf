variable "yc_oauth_token" {
  type        = string
  sensitive   = true
  description = "Yandex Cloud OAuth token"
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Folder ID"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for access to VMs"
}

variable "my_home_ip" {
  type        = string
  sensitive   = true
  description = "My home public IP for bastion SSH access (with /32)"
}
