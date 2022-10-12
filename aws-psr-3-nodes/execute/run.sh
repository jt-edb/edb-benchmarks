#!/bin/bash -eux

SSH_USER=cloud-user
export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python

# Run the benchmark
# 40 clients
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "pgbench_duration=${PGBENCH_DURATION}" \
	-e "pg_synchronous_commit=${PG_SYNCHRONOUS_COMMIT}" \
	-e "pgbench_client=40" \
	./playbook-pgbench-run.yml
# 80 clients
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "pgbench_duration=${PGBENCH_DURATION}" \
	-e "pg_synchronous_commit=${PG_SYNCHRONOUS_COMMIT}" \
	-e "pgbench_client=80" \
	./playbook-pgbench-run.yml
# 120 clients
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "pgbench_duration=${PGBENCH_DURATION}" \
	-e "pg_synchronous_commit=${PG_SYNCHRONOUS_COMMIT}" \
	-e "pgbench_client=120" \
	./playbook-pgbench-run.yml
# 160 clients
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "pgbench_duration=${PGBENCH_DURATION}" \
	-e "pg_synchronous_commit=${PG_SYNCHRONOUS_COMMIT}" \
	-e "pgbench_client=160" \
	./playbook-pgbench-run.yml
