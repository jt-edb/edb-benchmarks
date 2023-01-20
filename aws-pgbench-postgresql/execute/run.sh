#!/bin/bash -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SSH_USER=rocky

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

# Execute the playbook for each PostgreSQL version
versions=($(echo $PG_VERSIONS | tr -d '[],'))
for version in "${versions[@]}"
do
	# Execute benchmark
	ansible-playbook \
		-u ${SSH_USER} \
		--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
		-i ${SCRIPT_DIR}/../inventory.yml \
		-e "@${SCRIPT_DIR}/../vars.yml" \
		-e "pg_version=${version}" \
		-e "pgbench_mode=${PGBENCH_MODE}" \
		${SCRIPT_DIR}/playbook-pgbench-run.yml
done

# Generate final data points and chart
python3 ${SCRIPT_DIR}/post-processing.py
