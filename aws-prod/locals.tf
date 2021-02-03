# This file defines the common configuration shared across environments

locals {
  # AWS Profile Name
  # NOTE: if you change this value you must also update the profile name
  # in the terraform state configuration in main.tf:24
  profile  = "demo"

  # --- VPC Settings ---
  region   = terraform.workspace == "default" ? "Error: Please set your terraform workspace to a valid region!" : terraform.workspace
  vpc_cidr = "10.0.0.0/16"

  private_subnets_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  public_subnets_cidrs = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
  # --- End VPC Settings ---

}
