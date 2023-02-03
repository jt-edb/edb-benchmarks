#!/bin/bash -eu

VUSER_MIN=${TPCC_VUSER_MIN:=5}
VUSER_MAX=${TPCC_VUSER_MAX:=100}
VUSER_STEP=${TPCC_VUSER_STEP:=5}
# Execute HammerDB for 10mins at each number of vuser
DURATION=${TPCC_DURATION:=10}
RAMPUP=${TPCC_RAMPUP:=1}
WAREHOUSE=${TPCC_WAREHOUSE:=2000}
HAMMERDB_BIN_PATH=/opt/HammerDB-4.6
PG_SUPERUSER="${PG_SUPERUSER:=enterprisedb}"
PG_PORT=${PG_PORT:=5444}

RUNTIMER=$(expr ${DURATION} * 60 + ${RAMPUP} * 60)

# We must be in HammerDB installation path if we want to execute hammerdbcli
cd $HAMMERDB_BIN_PATH

echo "vuser,nopm"
echo "0,0"

for ((c=${VUSER_MIN}; c<${VUSER_MAX}; c=c+${VUSER_STEP}))
do
    # Write the runner TCL script including the wanted number of vuser
    cat << EOF > /tmp/runner-${c}-vuser.tcl
#!/usr/bin/env tclsh

proc runtimer { seconds } {
set x 0
set timerstop 0
while {!\$timerstop} {
incr x
after 1000
  if { ![ expr {\$x % 60} ] } {
          set y [ expr \$x / 60 ]
          puts "Timer: \$y minutes elapsed"
  }
update
if {  [ vucomplete ] || \$x eq \$seconds } { set timerstop 1 }
    }
return
}

dbset db pg
diset connection pg_host ${PG_HOST}
diset connection pg_port ${PG_PORT}
diset tpcc pg_raiseerror true
diset tpcc pg_superuser ${PG_SUPERUSER}
diset tpcc pg_count_ware ${WAREHOUSE}
diset tpcc pg_driver timed
diset tpcc pg_duration ${DURATION}
diset tpcc pg_rampup ${RAMPUP}
diset tpcc pg_allwarehouse true
diset tpcc pg_num_vu ${c}
vuset logtotemp 1
loadscript
vuset vu ${c}
vucreate
vurun
runtimer ${RUNTIMER}
vudestroy
after 5000

exit
EOF

    nopm=$(./hammerdbcli tcl auto /tmp/runner-${c}-vuser.tcl | grep "System achieved" | sed -E "s/^.*achieved ([0-9\.]+).* NOPM.*$/\1/")
    echo "${c},${nopm}"
    rm -f /tmp/runner-${c}-vuser.tcl
    sleep 5
done
