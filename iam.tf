locals {
    //my list of users and their corresponding roles
  user_roles = {
    "nan.kang@datatonic.com" = ["roles/browser"],
    "abdikarim.dilib@datatonic.com" = ["roles/browser"],
    "alice.staton@datatonic.com" = ["roles/browser"],
    "ferda.ustun@datatonic.com" = ["roles/browser"],
    "kumail.kermalli@datatonic.com" = ["roles/browser"],
    "lily.relph@datatonic.com" = ["roles/browser"],
    "miles.trevethan@datatonic.com" = ["roles/browser"],
    "mohamed.khadar@datatonic.com" = ["roles/browser"],
    "ronak.patel@datatonic.com" = ["roles/browser"],
    "sabah.hussain@datatonic.com" = ["roles/browser"],
  }

  /*
    Builds an structure that looks like the following, with an entry
    for each user, and each role they have
    [
        {
            "role" = "roles/browser"
            "user" = "abdikarim.dilib@datatonic.com"
        },
        {
            "role" = "roles/browser"
            "user" = "alice.staton@datatonic.com"
        },...
  */
  privliges = flatten([
    for user_key, roles in local.user_roles : [
        for role in roles :
        {
            user = user_key,
            role = role
        }
    ]
  ])
}

# output "roles" {
#   value = { for entry in local.privliges: "${entry.user}.${entry.role}" => entry }
# }

resource "google_project_iam_member" "user_roles" {
  for_each = { for entry in local.privliges: "${entry.user}.${entry.role}" => entry }
  project = var.project_id
  role    = each.value.role
  member  = format("user:%s", each.value.user)
}
