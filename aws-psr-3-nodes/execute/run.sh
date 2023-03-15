#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SSH_USER=rocky
export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

# Run the ramping up benchmark
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ${SCRIPT_DIR}/../inventory.yml \
	-e "@${SCRIPT_DIR}/../vars.yml" \
	-e "tpcc_warehouse=${TPCC_WAREHOUSE}" \
	-e "tpcc_duration=${TPCC_DURATION}" \
	-e "tpcc_rampup=${TPCC_RAMPUP}" \
	-e "tpcc_min_vusers=${TPCC_MIN_VUSERS}" \
	-e "tpcc_max_vusers=${TPCC_MAX_VUSERS}" \
	-e "tpcc_step_vusers=${TPCC_STEP_VUSERS}" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	${SCRIPT_DIR}/playbook-tpcc-run-rampup.yml
