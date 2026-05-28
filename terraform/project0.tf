# Project 0: Foundation Infrastructure Orchestrator
# This module handles GCP APIs (Phase A) and Networking/Registry (Phase B).

module "project0" {
  source = "./modules/project0"

  project_id             = var.compute_project_id
  project_number         = var.compute_project_number
  region                 = var.compute_region
  bootstrap              = var.bootstrap
  
  # Ensure providers are passed down if needed, 
  # though they are now centralized in the root directory.
}