#!/bin/bash -eux

RUNDIR=$(readlink -f "${BASH_SOURCE[0]}")
RUNDIR=$(dirname "$RUNDIR")

edb-terraform "${TERRAFORM_PROJECT_PATH}" ../infrastructure.yml
cd "${TERRAFORM_PROJECT_PATH}"
terraform init
terraform apply -var-file=./terraform_vars.json -auto-approve

OUTPUT=$(biganimal create-cluster --cluster-config-file "${RUNDIR}/../ba-infrastructure.yml" -y 2>&1)
PATTERN='"(.+)"'
[[ $OUTPUT =~ $PATTERN ]]
BAID="${BASH_REMATCH[1]}"

BIGANIMALIDFILE="${TERRAFORM_PROJECT_PATH}/biganimal-id"

echo "$BAID" > "${BIGANIMALIDFILE}"

# TODO: We're only checking if the cluster is healthy.  May need more logic to
# handle other situations or to reply on buildbot to time out after a certain
# amount of time.
RC=0
while [ $RC -ne 1 ]; do
	RC=$(biganimal show-clusters --id "$BAID" | grep "\<$BAID\>" | grep -c "Cluster in healthy state" || exit 0)
	biganimal show-clusters --id "$BAID"
	sleep 2
done

#
# Manually append servers.yml file with BigAnimal details.
#

TOOMUCHINFO=$(biganimal show-cluster-connection --id "$BAID" | grep read-write)

PATTERN='@(.+):'
[[ $TOOMUCHINFO =~ $PATTERN ]]
BAADDRESS="${BASH_REMATCH[1]}"

PATTERN='postgresql://(.+)@'
[[ $TOOMUCHINFO =~ $PATTERN ]]
BAPGUSER="${BASH_REMATCH[1]}"

cat >> "${TERRAFORM_PROJECT_PATH}/servers.yml" << EOF
  databases:
    dbt2:
      region: us-east-1
      username: "$BAPGUSER"
      password: "1234567890zyx"
      address: $BAADDRESS
      port: 5432
      dbname: "dbt2"
EOF
