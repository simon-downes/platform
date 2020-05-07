# Terraform State

This Terraform definition is responsible for creating the AWS resources
(S3 bucket and DynamoDB table) required to store Terraform state.

The resource names are specified in the `backend.tfvars` file located in the
top-level Terraform directory of the repo.

The variables are named such that they can be used as both a backend config
file to be passed to `terraform init` and as a variables file to be passed to
`terraform plan/apply/destroy`.

Initially there is no state backend so the `backend` block should be commented
out and the resources created by running the following command:
`terraform apply -var-file="../../backend.tfvars"`

Once the resources are created we need to convert the state backend to S3 by
uncommenting the `backend` block in `main.tf` and running
`terraform init -backend-config="../../backend.tfvars"`

This will then migrate the state from the local state file to the S3 bucket.
We can then delete the local `terraform.tfstate` file and it's backup.
