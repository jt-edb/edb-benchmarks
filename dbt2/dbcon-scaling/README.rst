=============================================
1000 Warehouse (~100 GB) Altered 3-tier Tests
=============================================

Description
===========

Characterize system performance as the number of database connections increase.

This is a 3-tier client-server scenario where every emulated terminal will
randomly emulate a different warehouse/district pair in the database without
using any thinking or keying time per transaction.

1000 warehouses is arbitrarily chosen for this example.  It may be changed to
any number desired.  For example, it may be interesting to try 10,000
Warehouses as that generates roughly 1 TB of data.

Rampup time is fairly minimal as these are primarily a small number of emulated
terminals, less than 100, which can be ramped up relatively quickly.  But keep
an eye on the various data caches as how fast the database warms up may vary.

A 1 hour steady state duration is used to give a fair degree of confidence in
the stability of the primary metric.  But further review of the system
statistics is needed to confirm the system is actually stable.

Create the database the 1000 warehouse database with the following command
(note additional flags may be needed depending on how the database is
provisioned, i.e. DBaaS, from source, etc)::

    dbt2-pgsql-build-db -w 1000

Edit the `runme.sh` to set the environment variables correctly:

* `TERMINALS` - A list of the number of emulated terminals to test.
* `CONNECTIONS` - The number of database connections to open.
* `DBADDRESS` - The host address of the database server.
* `CLIENTADDRESS` - The host address of the client system
* `TAG` - A identifier to separate different series of tests, e.g. small,
  medium, large, xl, etc. by incorporating it in the results directory name.
* `WAREHOUSES` - The number of warehouses to match the number used to build the
  database.

Note that for ease of testing the number of database connections needs to be
higher `CONNECTIONS` than `TERMINALS`.  The value for `TERMINALS` is synonymous
with the number of database connections actively used as each terminal will use
only one database connection.

Also note that the total number of database connections allowed by the database
needs to be higher than `CONNECTIONS`.  Pad with an additional 10 connection to
account for additional connections that collect data.  

Execute the `runme.sh` scripts to iterate through all of the test parameters.
