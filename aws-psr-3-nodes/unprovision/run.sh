#!/bin/bash -eux

cd ${TERRAFORM_PROJECT_PATH}
terraform destroy -var-file=./terraform_vars.json -auto-approve
