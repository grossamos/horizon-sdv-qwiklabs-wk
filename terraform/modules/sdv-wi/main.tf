data "google_project" "project" {}

resource "google_service_account" "sdv_wi_sa" {
  for_each = var.wi_service_accounts

  project      = data.google_project.project.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}

# resource "terraform_data" "debug_wi_service_accounts" {
#   input = var.wi_service_accounts
# }

locals {
  flattened_roles_with_sa = flatten([
    for sa_key, sa_value in var.wi_service_accounts : [
      for role in sa_value.roles : {
        sa_id      = sa_key
        account_id = sa_value.account_id
        role       = role
      }
    ]
  ])

  roles_with_sa_map = {
    for item in local.flattened_roles_with_sa : "${item.role}-${item.sa_id}" => item
  }

  flattened_gke_sas = flatten([
    for sa_key, sa_value in var.wi_service_accounts : [
      for gke_sa in sa_value.gke_sas : {
        sa_id      = sa_key
        account_id = sa_value.account_id
        gke_ns     = gke_sa.gke_ns
        gke_sa     = gke_sa.gke_sa
      }
    ]
  ])

  gke_sas_with_sa_map = {
    for item in local.flattened_gke_sas : "${item.sa_id}-${item.gke_ns}-${item.gke_sa}" => item
  }
}

# resource "terraform_data" "debug_flattened_roles_with_sa" {
#   input = local.flattened_roles_with_sa
# }

# resource "terraform_data" "debug_roles_with_sa_map" {
#   input = local.roles_with_sa_map
# }

resource "google_project_iam_member" "sdv_wi_sa_iam_2" {
  for_each = local.roles_with_sa_map

  project = data.google_project.project.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sdv_wi_sa[each.value.sa_id].email}"

  depends_on = [
    google_service_account.sdv_wi_sa
  ]
}

resource "google_project_iam_member" "sdv_wi_sa_wi_users_gke_ns_sa" {
  for_each = local.gke_sas_with_sa_map

  project = data.google_project.project.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[${each.value.gke_ns}/${each.value.gke_sa}]"

  depends_on = [
    google_service_account.sdv_wi_sa
  ]
}
