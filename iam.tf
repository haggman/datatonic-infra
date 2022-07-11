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

//Now for the service accounts

//First, let's build the SAs. 
//Create the SA for composer to use
resource "google_service_account" "composer_sa" {
  account_id   = "sa-pipeline-composer"
  display_name = "Composer pipeline's SA"
  project      = var.project_id
}

//Create the SA that deploys to Composer
resource "google_service_account" "composer_deployer_sa" {
  account_id   = "sa-composer-deployer"
  display_name = "Composer Deployer"
  project      = var.project_id
}

//Create the SA for Cloud Run to use
resource "google_service_account" "run_sa" {
  account_id   = "forecast-accessor"
  display_name = "Cloud Run app SA (Forecast accessor)"
  project      = var.project_id
}

//Create the SA for Cloud Run deployer
resource "google_service_account" "run_deployer_sa" {
  account_id   = "sa-run-data-loader-deployer"
  display_name = "Cloud Run deployer"
  project      = var.project_id
}



//Setup the permissions and do the flatten
locals {
  sa_roles = {
    //Cloud composer SA
    (google_service_account.composer_sa.email)        = ["roles/composer.worker"],
    //Cloud composer deployer
    (google_service_account.composer_deployer_sa.email) = ["roles/storage.objectAdmin"],
    //Cloud Run
    (google_service_account.run_sa.email) = ["roles/iam.serviceAccountUser"],
    //Cloud Run deployer
    (google_service_account.run_deployer_sa.email) = [
                                                    "roles/run.admin",
                                                    "roles/storage.admin", //Really only needed for first push (Creates initial GCR bucket)
                                                    "roles/iam.serviceAccountUser"
                                                  ],
    
  }

    //Flatten the SAs and their respective permissions. 
    sa_privileges = flatten([
    for user_key, roles in local.sa_roles : [
      for role in roles :
      {
        user = user_key,
        role = role
      }
    ]
  ])
}

//Apply the permissions
resource "google_project_iam_member" "sa_roles" {
  for_each = { for entry in local.sa_privileges : "${entry.user}.${entry.role}" => entry }
  project  = var.project_id
  role     = each.value.role
  member   = format("serviceAccount:%s", each.value.user)
}