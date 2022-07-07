locals {
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
    "sabah.hussain@datatonic.com" = ["roles/browser"]
  }

  privliges = flatten([
    for user in local.user_roles : [
        user
    ]
  ])
  
}

output "users" {
  value = local.privliges
}

