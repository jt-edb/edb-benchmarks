#!/bin/sh

# Make sure all of these environment variables are set or else the test wont
# run correctly!
TERMINALS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 18 20 22 24 26 28 30 32 36 40 44 48 52 56 60 64"
CONNECTIONS=128
DBADDRESS=
DURATION=3600
CLIENTADDRESS=
TAG=
WAREHOUSES=1000

for C in $TERMINALS; do
	dbt2-run-workload -a pgsql -D dbt2 -c $C -d $DURATION -w $WAREHOUSES -A \
			-H $DBADDRESS -C $CLIENTADDRESS -L $C -n -s 100 -u -y \
			-o ${TAG}-${WAREHOUSES}w-c${CONNECTIONS}-d${C}
done
