#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SSH_USER=rocky

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_ARGS="-o ForwardX11=no -o UserKnownHostsFile=/dev/null"
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

ansible-playbook \
	-u ${SSH_USER} \
	--private-key "${TERRAFORM_PROJECT_PATH}/ssh-id_rsa" \
	-i "${SCRIPT_DIR}/../inventory.yml" \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	-e "dbt2_warehouse=${DBT2_WAREHOUSE}" \
	"${SCRIPT_DIR}/playbook-dbt2-build-db.yml"
