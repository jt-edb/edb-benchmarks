#!/bin/bash -eux

SSH_USER=rocky

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

# Prepare benchmark
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "{\"pg_versions\": ${PG_VERSIONS}}" \
	-e "pgbench_scale_factor=${PGBENCH_SCALE_FACTOR}" \
	./playbook-pgbench-init.yml
