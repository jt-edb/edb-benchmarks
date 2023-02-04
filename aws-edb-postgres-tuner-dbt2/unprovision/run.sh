#!/bin/bash -eux

cd "${TERRAFORM_PROJECT_PATH}"
terraform destroy -auto-approve
