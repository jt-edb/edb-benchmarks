#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

edb-terraform ${TERRAFORM_PROJECT_PATH} ${SCRIPT_DIR}/../infrastructure.yml
cd ${TERRAFORM_PROJECT_PATH}
terraform init
terraform apply -var-file=./terraform_vars.json -auto-approve
