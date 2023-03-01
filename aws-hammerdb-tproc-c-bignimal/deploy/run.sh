#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SSH_USER=rocky

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

python3 ./build-inventory.py "${TERRAFORM_PROJECT_PATH}"
mv inventory.yml ../.

ansible-playbook \
	-u ${SSH_USER} \
	--private-key "${TERRAFORM_PROJECT_PATH}/ssh-id_rsa" \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "tprocc_duration=${TPROCC_DURATION}" \
	-e "tprocc_vusers=${TPROCC_VUSERS}" \
	-e "tprocc_warehouse=${TPROCC_WAREHOUSE}" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	./playbook-deploy.yml
