#!/bin/sh

# Make sure all of these environment variables are set!
CLIENTADDRESS=
CONNECTIONS="100"
DBADDRESS=
DURATION=3600
TAG=
WAREHOUSES="100 200 300 400 500 600 700 800 900 1000"

for W in $WAREHOUSES; do
	ssh $DBADDRESS -- dropdb dbt2
	ssh $DBADDRESS -- ". .dbt2rc; dbt2-pgsql-build-db -u -w $W"
	dbt2-run-workload -a pgsql -D dbt2 -c $CONNECTIONS -d $DURATION -w $W -A \
			-H $DBADDRESS -C $CLIENTADDRESS -n -s 100 -u -y -L $CONNECTIONS \
			-o ${TAG}-${W}w-c${CONNECTIONS}
done
