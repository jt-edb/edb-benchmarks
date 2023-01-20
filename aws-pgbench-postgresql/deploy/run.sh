#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SSH_USER=rocky

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

python3 ${SCRIPT_DIR}/build-inventory.py ${TERRAFORM_PROJECT_PATH}
mv ${SCRIPT_DIR}/inventory.yml ${SCRIPT_DIR}/../.

# Setup file systems
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	${SCRIPT_DIR}/playbook-setup-fs.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "{\"pg_versions\": ${PG_VERSIONS}}" \
	${SCRIPT_DIR}/playbook-deploy.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "{\"pg_versions\": ${PG_VERSIONS}}" \
	${SCRIPT_DIR}/playbook-setup-pg.yml
