#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SSH_USER=rocky
export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

# Run the ramping up benchmark for the encrypted instance
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "tpcc_warehouse=${TPCC_WAREHOUSE}" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	-e "use_tde=1" \
	${SCRIPT_DIR}/playbook-tpcc-run-rampup.yml

# Run the ramping up benchmark for the unencrypted instance
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "tpcc_warehouse=${TPCC_WAREHOUSE}" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	-e "use_tde=0" \
	${SCRIPT_DIR}/playbook-tpcc-run-rampup.yml

# Run the benchmark for the encrypted instance
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "tpcc_duration=${TPCC_DURATION}" \
	-e "tpcc_rampup=${TPCC_RAMPUP}" \
	-e "tpcc_warehouse=${TPCC_WAREHOUSE}" \
	-e "tpcc_vusers=${TPCC_VUSERS}" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	-e "use_tde=1" \
	${SCRIPT_DIR}/playbook-tpcc-run.yml

# Run the benchmark for the unencrypted instance
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "tpcc_duration=${TPCC_DURATION}" \
	-e "tpcc_rampup=${TPCC_RAMPUP}" \
	-e "tpcc_warehouse=${TPCC_WAREHOUSE}" \
	-e "tpcc_vusers=${TPCC_VUSERS}" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	-e "use_tde=0" \
	${SCRIPT_DIR}/playbook-tpcc-run.yml

# Generate charts
python3 ${SCRIPT_DIR}/post-processing.py
