#!/bin/bash -eux

cd "${TERRAFORM_PROJECT_PATH}"
terraform destroy -var-file=./terraform_vars.json -auto-approve

BIGANIMALIDFILE="${TERRAFORM_PROJECT_PATH}/biganimal-id"
BAID=$(<"$BIGANIMALIDFILE")

biganimal delete-cluster --id "$BAID" -y
# TODO: how to make script wait until bignimal finishes destroying cluster?
