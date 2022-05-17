locals {
  cloud_id  = "b1gqrp1i6qksiv3fsd7p"
  folder_id = "b1gtnhq0jsadaquuvpi6"
}

provider "yandex" {
  service_account_key_file = "/home/wizard/.yckey.json"
  cloud_id                 = local.cloud_id
  folder_id                = local.folder_id
  zone                     = var.zones[1]
}
