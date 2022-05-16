=============================================
10,000 Warehouse (~1 TB) Altered 2-tier Tests
=============================================

Description
===========

This is a 2-tier client-server scenario where every emulated terminal may
emulate any warehouse/district pair in the database without using any thinking
or keying time.

This example uses the consolidated driver/client event model where the number
of database connections is a function of how many processors are available on
the driver system.

Rampup time is fairly minimal as these are primarily a small number of emulated
terminals, less than 100, which can be ramped up relatively quickly.

A 1 hour steady state duration is used to give a fair degree of confidence in
the stability of the primary metric.  But further review of the the system
statistics is needed to confirm the system is actually stable.

Create the database the 10,000 warehouse database with (note additional flags
may be needed depending on how the database is provisioned, i.e. DBaaS, from
source, etc)::

    dbt2-pgsql-build-db -w 10000

Edit the `runme.sh` to set the environment variables correctly.

* `TERMINALS` - A list of the number of emulated terminals to test.
* `TPW` - The number of database connections to open per processor.
* `DBADDRESS` - The host address of the database server.
* `TAG` - A identifier to separate different series of tests, e.g. small,
  medium, large, xl, etc.

Execute the `runme.sh` scripts to interate through all of the test parameters.
