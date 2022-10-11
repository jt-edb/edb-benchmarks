#!/bin/bash -eux

SSH_USER=cloud-user
export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "pgbench_scale_factor=${PGBENCH_SCALE_FACTOR}" \
	./playbook-pgbench-init.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	./playbook-efm.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	./playbook-proxy.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "pg_synchronous_commit=${PG_SYNCHRONOUS_COMMIT}" \
	./playbook-synchronous-commit.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "pgbench_scale_factor=${PGBENCH_SCALE_FACTOR}" \
	./playbook-client.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "pg_additional_network_latency=${PG_ADDITIONAL_NETWORK_LATENCY}" \
	./playbook-add-network-latency.yml
