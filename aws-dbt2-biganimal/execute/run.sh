#!/bin/bash -eux

SSH_USER=rocky
export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

# Run the benchmark
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "dbt2_duration=${DBT2_DURATION}" \
	-e "dbt2_warehouse=${DBT2_WAREHOUSE}" \
	-e "dbt2_connections=${DBT2_CONNECTIONS}" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	./playbook-dbt2-run.yml
