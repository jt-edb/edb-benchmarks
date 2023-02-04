#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SSH_USER=rocky

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_ARGS="-o ForwardX11=no -o UserKnownHostsFile=/dev/null"
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

python3 "${SCRIPT_DIR}/build-inventory.py" "${TERRAFORM_PROJECT_PATH}"
mv "${SCRIPT_DIR}/inventory.yml" "${SCRIPT_DIR}/../."

ansible-playbook \
	-u ${SSH_USER} \
	--private-key "${TERRAFORM_PROJECT_PATH}/ssh-id_rsa" \
	-i "${SCRIPT_DIR}/../inventory.yml" \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "repo_username=${REPO_USERNAME}" \
	-e "repo_password=${REPO_PASSWORD}" \
	"${SCRIPT_DIR}/playbook-deploy.yml"
