#!/bin/bash -eux

SSH_USER=cloud-user
export ANSIBLE_PIPELINING=true
export ANSIBLE_SSH_PIPELINING=true
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python

python3 ./build-inventory.py ${TERRAFORM_PROJECT_PATH}
mv inventory.yml ../.

ansible-playbook \
	-u ${SSH_USER} \
	--private-key ${TERRAFORM_PROJECT_PATH}/ssh-id_rsa \
	-i ../inventory.yml \
	-e "@../vars.yml" \
	-e "pg_type=${PG_TYPE}" \
	-e "pg_version=${PG_VERSION}" \
	-e "repo_username=${REPO_USERNAME}" \
	-e "repo_password=${REPO_PASSWORD}" \
	./playbook-deploy.yml
