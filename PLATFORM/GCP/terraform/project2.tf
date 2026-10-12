module "project2" {
  source = "./modules/project2"

  gcp_project_id               = var.compute_project_id
  gcp_region                   = var.compute_region
  service_name                 = var.service_name
  vpc_connector_id             = module.project0.connector_id
  mongodb_atlas_org_id         = var.atlas_org_id
  mongodb_atlas_cluster_region = var.mongodb_atlas_cluster_region

  depends_on = [module.project0.private_vpc_connection]
}
