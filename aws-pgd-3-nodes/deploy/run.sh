#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SSH_USER=rocky

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

# Create the TPA directory
mkdir -p ${SCRIPT_DIR}/tpa

python3 ${SCRIPT_DIR}/build-inventory.py ${TERRAFORM_PROJECT_PATH}
mv ${SCRIPT_DIR}/inventory.yml ${SCRIPT_DIR}/../.

# TPA configuration
TPA_BIN_DIR=/opt/EDB/TPA/bin

TPA_DIR=${SCRIPT_DIR}/tpa
mv ${SCRIPT_DIR}/config.yml ${TPA_DIR}/.
mv ${SCRIPT_DIR}/edb-repo-creds.txt ${TPA_DIR}/.
chmod 0600 ${TPA_DIR}/edb-repo-creds.txt
export EDB_REPO_CREDENTIALS_FILE=${TPA_DIR}/edb-repo-creds.txt

${TPA_BIN_DIR}/tpaexec relink ${TPA_DIR}
${TPA_BIN_DIR}/tpaexec provision ${TPA_DIR}

# Setup file systems
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	${SCRIPT_DIR}/playbook-setup-fs.yml

# TPA deployment
${TPA_BIN_DIR}/tpaexec deploy ${TPA_DIR}

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	${SCRIPT_DIR}/playbook-deploy.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	${SCRIPT_DIR}/playbook-hammerdb-setup.yml
