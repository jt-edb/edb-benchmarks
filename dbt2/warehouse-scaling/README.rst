=================
Warehouse Scaling
=================

Description
===========

This is a 3-tier client-server scenario where every emulated terminal will
randomly emulate a different warehouse/district pair in the database without
using any thinking or keying time per transaction.

A 1 hour steady state duration is used to give a fair degree of confidence in
the stability of the primary metric.  But further review of the system
statistics is needed to confirm the system is actually stable.

This script assumes there is password-less ssh access from the driver system to
the database system in order to rebuild the database for every test.  It also
assumes a shell resource file `.dbt2rc` exists such that it can run the
`dbt2-pgsql-build-db` correctly.

This test will use a consistent number of emulated terminals and database
connections to determine how the throughput changes as the database size grows.

Edit the `runme.sh` to set the environment variables correctly.

* `CLIENTADDRESS` - The host address of the client system
* `CONNECTIONS` - The number of database connections to open.
* `DBADDRESS` - The host address of the database server.
* `TAG` - A identifier to separate different series of tests, e.g. small,
  medium, large, xl, etc.
* `WAREHOUSES` - A list of warehouse sizes to test.

Execute the `runme.sh` scripts to iterate through all of the test parameters.
