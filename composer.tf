

//Create the Composer instance
resource "google_composer_environment" "pipeline_composer_instance" {
  name   = "pipeline-composer"
  region = var.gcp_region

  config {
    //Going to try Cloud Composer v2
    software_config {
      image_version = "composer-2.0.19-airflow-2.2.5"
      pypi_packages = {
        dbt-core     = ""
        dbt-bigquery = ""
        airflow-dbt  = ""
      }

      env_variables = {
        DBT_PROFILES_DIR = "/home/airflow/gcs/data/profiles"
      }
    }
    node_config {
      service_account = google_service_account.composer_sa.email
      network         = module.vpc.network_id
      subnetwork      = module.vpc.subnets_ids[0]

      ip_allocation_policy {
        cluster_secondary_range_name  = "composer-cluster-pods"
        services_secondary_range_name = "composer-cluster-services"
      }
    }

    //Set cluster to use private IPs
    private_environment_config {
      enable_private_endpoint              = true
      master_ipv4_cidr_block               = var.composer_master_cidr
      cloud_composer_connection_subnetwork = module.vpc.subnets_ids[0]
    }
  }
}

// Create a new namespace for the dbt container to use

# Get the credentials 
resource "null_resource" "get-credentials" {

 depends_on = [google_composer_environment.pipeline_composer_instance] 
 
 provisioner "local-exec" {
   command = "gcloud container clusters get-credentials ${google_composer_environment.pipeline_composer_instance.config[0].gke_cluster} --region europe-west2"
 }
}

# Create a namespace
resource "kubernetes_namespace" "dbt-namespace" {

 depends_on = [null_resource.get-credentials]

 metadata {
   name = "dbt-pipeline"
 }
}


