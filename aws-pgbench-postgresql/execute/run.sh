#!/bin/bash -eux

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
		-i ../inventory.yml \
		-e "@../vars.yml" \
		-e "pg_version=${version}" \
		./playbook-pgbench-run.yml
done

# Generate final data points and chart
python3 ./post-processing.py
