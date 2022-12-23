#!/bin/bash -eux

SSH_USER=admin

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

python3 ${SCRIPT_DIR}/build-inventory.py ${TERRAFORM_PROJECT_PATH}
mv ${SCRIPT_DIR}/inventory.yml ${SCRIPT_DIR}/../.

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	${SCRIPT_DIR}/playbook-deploy.yml
