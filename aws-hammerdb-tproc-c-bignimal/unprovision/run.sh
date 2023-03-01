#!/bin/bash -eux

# We need the absolute path of $TERRAFORM_PROJECT_PATH in this script.
TERRAFORM_PROJECT_PATH=$(readlink -f "${TERRAFORM_PROJECT_PATH}")

cd "${TERRAFORM_PROJECT_PATH}"
terraform destroy -auto-approve

BIGANIMALIDFILE="${TERRAFORM_PROJECT_PATH}/biganimal-id"
BAID=$(<"$BIGANIMALIDFILE")

biganimal delete-cluster --id "$BAID" -y
# TODO: how to make script wait until bignimal finishes destroying cluster?
