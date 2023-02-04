This test is to demonstrated the effectiveness of EDB Postgres Tuner with a
TPC-C like workload.

EDB Postgres Tuner documentation:
https://www.enterprisedb.com/docs/pg_extensions/pg_tuner/

EDB Postgres Tuner will run a check every 10 minutes by default.  For this
series of tests, we will leave the default EDB Postgres Tuner at 10 minutes and
bake in a 15 minute ramp up time.  Thus at least 10 minutes of steady state
should be planned to:

1. Measure the throughout using default database settings, with EDB Postgres
   Tuner.
2. Run another test with EDB Postgres Tuner enabled to gather recommendations.
3. Run a final test with the EDB Postgres Tuner recommendations applied,
   because there may be a recommendation from the previous test that was not
   applied until the database was restarted.
