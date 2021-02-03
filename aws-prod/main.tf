################################################################################
# Main Module                                                                  #
# This module sets up the provider and terraform state.                        #
# It will also create a s3 bucket for state storage and a DynamoDB table for   #
# managing state-locks.                                                        #
################################################################################

provider "aws" {
  profile = local.profile
  region  = local.region
}

# terraform state configuration
terraform {
  required_version = "~> 0.14"

  backend "s3" {
    bucket               = "tfstate-production-poc"
    dynamodb_table       = "tfstate-production-locks"
    encrypt              = true
    key                  = "terraform.tfstate"
    region               = "us-west-2"
    workspace_key_prefix = "production"
    profile              = "demo" # NOTE: update me if you change local.profile
    # path pattern: s3://<bucket>/<workspace_key_prefix>/<workspace-name>/<key>
  }
}

# terraform bucket to store state
module "terraform-state-bucket" {
  count                   = terraform.workspace == "us-west-2" ? 1 : 0 # create the bucket only in us-west-2
  source                  = "terraform-aws-modules/s3-bucket/aws"
  bucket                  = "tfstate-production-poc"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning = {
    enabled = true
  }
}

# Create DynamoDB table for managing Terraform locks
module "terraform-state-locks" {
  count          = terraform.workspace == "us-west-2" ? 1 : 0 # create the table only in us-west
  source         = "terraform-aws-modules/dynamodb-table/aws"
  name           = "tfstate-production-locks"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attributes = [{
    name = "LockID"
    type = "S"
  }]
}
