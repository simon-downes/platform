#!/bin/bash
echo "bucket         = $(aws ssm get-parameter --with-decryption --name sdc-terraform-backend-bucket| jq .Parameter.Value)" > backend.tfvars
echo "dynamodb_table = $(aws ssm get-parameter --with-decryption --name sdc-terraform-backend-bucket| jq .Parameter.Value)" >> backend.tfvars
echo "region         = \"eu-west-2\"" >> backend.tfvars
