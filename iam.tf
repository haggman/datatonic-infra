//Setup some access for the students
locals {
  //my list of users and their corresponding roles
  user_roles = {
    "nan.kang@datatonic.com"        = ["roles/browser"],
    "abdikarim.dilib@datatonic.com" = ["roles/browser"],
    "alice.staton@datatonic.com"    = ["roles/browser"],
    "ferda.ustun@datatonic.com"     = ["roles/browser"],
    "kumail.kermalli@datatonic.com" = ["roles/browser"],
    "lily.relph@datatonic.com"      = ["roles/browser"],
    "miles.trevethan@datatonic.com" = ["roles/browser"],
    "mohamed.khadar@datatonic.com"  = ["roles/browser"],
    "ronak.patel@datatonic.com"     = ["roles/browser"],
    "sabah.hussain@datatonic.com"   = ["roles/browser"],
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
  privileges = flatten([
    for user_key, roles in local.user_roles : [
      for role in roles :
      {
        user = user_key,
        role = role
      }
    ]
  ])
}

/*
    Configure all the roles. Ok, so the above generated a tuple of objects, each one
    containing a user and a role. To convert each to something more palatable for the 
    Terraform for_each, I used:
    for_each = { for entry in local.privileges: "${entry.user}.${entry.role}" => entry }
    You can go read more about that for here: https://www.terraform.io/language/expressions/for
    Essentially, it's used to convert one complex type to another. In this case, for each
    element in my incoming tuple of objects, I want a single map { }, where the key is
    user.role and the value (=>) is the object itself, 
    {
            "role" = "some role"
            "user" = "some user"
    }
*/

resource "google_project_iam_member" "user_roles" {
  for_each = { for entry in local.privileges : "${entry.user}.${entry.role}" => entry }
  project  = var.project_id
  role     = each.value.role
  member   = format("user:%s", each.value.user)
}

//Create the SA for composer to use
resource "google_service_account" "composer_sa" {
  account_id   = "sa-pipeline-composer"
  display_name = "Composer pipeline's SA"
  project      = var.project_id
}

//Set the permissions on the composer SA

locals {
  roles_for_sa = toset([
    "roles/composer.worker"
  ])
}
resource "google_project_iam_member" "composer_sa_roles" {
  for_each = local.roles_for_sa
  project  = var.project_id
  role     = each.value
  member = format("serviceAccount:%s",
  google_service_account.composer_sa.email)
}