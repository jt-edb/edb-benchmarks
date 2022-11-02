#!/bin/bash -eux

SSH_USER=rocky
export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "terraform_project_path=${TERRAFORM_PROJECT_PATH}" \
	-e "dbt2_warehouse=${DBT2_WAREHOUSE}" \
	./playbook-dbt2-build-db.yml
