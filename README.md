# Terraform Demo

This project will create the following infrastructure in AWS:

* VPC (3 public subnets, 3 private subnets, nat gateways)
* EKS Cluster running a single t3a.medium spot instance
* S3 Bucket to store Terraform State
* DynamoDB table to hande Terraform state-locks

Estimated Monthly cost: 

```console
$ terraform state pull | curl -s -X POST -H "Content-Type: application/json" -d @- https://cost.modules.tf/ | jq
{
  "hourly": 0.05,
  "monthly": 34.56
}
```

## Bootstrapping the environment for the first time

To provision the environment for the first time you'll need to comment the s3 backend
block in `main.tf:17:26` like so:

```hcl
terraform {
  required_version = "~> 0.14"

  # backend "s3" {
  #   bucket               = "tfstate-production-poc"
  #   dynamodb_table       = "terraform-state-production-locks"
  #   encrypt              = true
  #   key                  = "terraform.tfstate"
  #   region               = "us-west-2"
  #   workspace_key_prefix = "production"
  #   profile              = "demo" # NOTE: update me if you change local.profile
  #   # path pattern: s3://<bucket>/<workspace_key_prefix>/<workspace-name>/<key>
  # }
}
```

## How it works

This code will allow you to deploy the same infrastructure to any AWS region.
To achieve this we rely on terraform worskpaces.

You can list the existing workspaces using `terraform workspace list`.
By default you should only have one workspace named `default`.
We'll be naming our workspaces with the AWS region name.

For example, we'll create a workspace for us-west-2:

```console
$ terraform workspace list
*  default
$ terraform workspace new us-west-2
$ terraform workspace list
  default
* us-west-2
```

Once the workspace for the appropiate region has been created we can begin deploying the
infrastructure. 

```console
$ terraform init
$ terraform plan -var-file=us-west-2.tfvars
$ terraform apply -var-file=us-west-2.tfvars
```

## Troubleshooting

If you created resources in the default workspace by mistake and need to migrate state fom
one workspace to another you can follow this excellent [guide](https://dev.to/igordcsouza_87/migrating-resources-from-the-default-workspace-to-a-new-one-3ojc).
