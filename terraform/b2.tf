provider "b2" {
  application_key = local.b2_application_key
  application_key_id = local.b2_application_key_id
}

locals {
  b2_application_key = sensitive(data.ansiblevault_path.b2_application_key.value)
  b2_application_key_id = sensitive(data.ansiblevault_path.b2_application_key_id.value)
}
