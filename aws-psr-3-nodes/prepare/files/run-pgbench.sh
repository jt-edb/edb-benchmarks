#!/bin/bash -eu

PGBENCH_CLIENT=$1
PGBENCH_DURATION=$2

python3 ./repl-lag-monitoring.py --pg "user={{ pgbench_user }} host={{ hostvars[groups['primary'][0]].private_ip }} dbname={{ pgbench_database }} port={{ pg_port }} password={{ pgbench_password }}" -d $((${PGBENCH_DURATION} + 5)) > /tmp/repl-lag_${PGBENCH_CLIENT}_${PGBENCH_DURATION}.csv 2>&1&
python3 ./wal-rate-monitoring.py --pg "user={{ pgbench_user }} host={{ hostvars[groups['primary'][0]].private_ip }} dbname={{ pgbench_database }} port={{ pg_port }} password={{ pgbench_password }}" -d $((${PGBENCH_DURATION} + 5))  > /tmp/wal-rate_${PGBENCH_CLIENT}_${PGBENCH_DURATION}.csv 2>&1&
PGPASSWORD={{ pgbench_password }} /usr/edb/as{{ pg_version }}/bin/pgbench \
	-s {{ pgbench_scale_factor }} \
	-j 8 \
	-c ${PGBENCH_CLIENT} \
	-T ${PGBENCH_DURATION} \
	-U {{ pgbench_user }} \
	-h {{ hostvars[groups['proxy'][0]].private_ip }} \
	-p {{ pg_port }} \
	{{ pgbench_database }} > /tmp/pgbench_${PGBENCH_CLIENT}_${PGBENCH_DURATION}.out 2>&1
