module "gce_instance_dev" {
  count         = terraform.workspace == "dev" ? 1 : 0
  source        = "./modules/gce_instance"
  project_id    = var.compute_project_id
  instance_name = "dev-instance"
}
