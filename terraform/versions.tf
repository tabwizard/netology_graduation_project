terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "pirozhkov-s3-terraform-graduation-netology"
    region     = "ru-central1"
    key        = "terraform/terraform.tfstate"
    access_key = "YCAJEmQkBtAKwZ-NbdjaPU5l1"
    secret_key = "YCOg3-E8HlCThjAPQ6XXMmIusPg5ToRu5DuLYJO4"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
