#!/bin/bash -eux

edb-terraform ${TERRAFORM_PROJECT_PATH} ../infrastructure.yml
cd ${TERRAFORM_PROJECT_PATH}
terraform init
terraform apply -auto-approve
