#!/bin/bash -eux

cd "${TERRAFORM_PROJECT_PATH}"
terraform destroy -var-file=./terraform_vars.json -auto-approve

biganimal delete-cluster --name dbt2 --provider aws --region us-east-1 -y
# TODO: how to make script wait until bignimal finishes destroying cluster?
