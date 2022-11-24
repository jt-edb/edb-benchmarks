#!/bin/bash -eux

SSH_USER=rocky

export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false

python3 ./build-inventory.py ${TERRAFORM_PROJECT_PATH}
mv inventory.yml ../.

# Setup file systems
ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	./playbook-setup-fs.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "{\"pg_versions\": ${PG_VERSIONS}}" \
	./playbook-deploy.yml

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "{\"pg_versions\": ${PG_VERSIONS}}" \
	./playbook-setup-pg.yml
