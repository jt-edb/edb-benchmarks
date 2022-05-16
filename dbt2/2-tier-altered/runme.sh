#!/bin/sh

# Make sure all of these environment variables are set!
TPW="1 2 3 4"
DBADDRESS=
TAG=

for C in $TPW; do
	dbt2-run-workload -a pgsql -D dbt2 -d 3600 -w 10000 -A \
			-H $DBIPADDRESS -n -s 100 -u -y -t $TPW -F $C \
			-o ${TAG}-10000w-d${C}conn
done
