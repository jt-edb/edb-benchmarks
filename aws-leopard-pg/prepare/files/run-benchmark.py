# coding: utf-8

import argparse
from multiprocessing import Process
import psycopg2
import subprocess
import sys
import time

def pgbench(pg_install_path, conn_string, duration, pgbench_client):
    cmd = subprocess.run(
        ['%s/bin/pgbench' % pg_install_path,
         '-f', '/tmp/update.sql',
         '-T', str(duration),
         '-c', str(pgbench_client),
         conn_string],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if cmd.returncode != 0:
        print("ERROR: pgbench execution failed")
        print(cmd.stderr.decode("utf-8"))
        sys.exit(1)


def monitor(conn_string, log_file):
    try:
        conn = psycopg2.connect(conn_string)
        conn.set_session(autocommit=True)
    except psycopg2.Error as e:
        sys.exit("ERROR: Unable to connect to the database")

    last_no_xact = 0
    snapshot_timestamp = None

    with open(log_file, "w") as f:
        i = 0
        f.write("timestamp,tps,pgbench_accounts_size,pgbench_accounts_total_size\n");

    while True:
        i += 1
        line = []

        cur = conn.cursor()
        cur.execute("""
            SELECT
                NOW(),
                SUM(pg_stat_get_db_xact_commit(oid))::BIGINT,
                pg_relation_size('pgbench_accounts'),
                pg_total_relation_size('pgbench_accounts')
            FROM pg_database
            WHERE datname = current_database()
        """)
        r = cur.fetchone()
        if i > 1:
            # Timestamp
            line.append(r[0].strftime("%Y-%m-%d %H:%M:%S.%f"))
            # Duration in second between each snapshot
            d = (r[0] - snapshot_timestamp).total_seconds()
            # TPS
            line.append("%.2f" % ((r[1] - last_no_xact) / d))
            line.append("%s" % r[2])
            line.append("%s" % r[3])

            with open(log_file, "a") as f:
                f.write(','.join(line))
                f.write('\n')

        # Record some informations needed for the next loop iteration
        snapshot_timestamp = r[0]
        last_no_xact = r[1]

        cur.close()
        time.sleep(30)


def long_transaction(conn_string, duration):
    try:
        conn = psycopg2.connect(conn_string)
        conn.set_session(autocommit=False)
    except psycopg2.Error as e:
        sys.exit("ERROR: Unable to connect to the database")

    cur = conn.cursor()
    cur.execute("BEGIN")
    cur.execute("INSERT INTO pgbench_accounts (aid, abalance) VALUES ((SELECT MAX(aid) FROM pgbench_accounts) + 1, 0)")
    time.sleep(duration + 10)
    cur.execute("ROLLBACK")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--pg',
        dest='pg',
        type=str,
        help="Postgres connection string.",
        default='',
    )
    parser.add_argument(
        '--duration', '-d',
        dest='duration',
        type=int,
        help="Benchmark duration, in seconds. Default: %(default)s",
        # Let's make it run for 8 hours by default
        default=28800,
    )
    parser.add_argument(
        '--pg-install-path',
        dest='pg_install_path',
        type=str,
        help="Postgres installation path. Default: %(default)s",
        default='/usr/local/pgsql-15',
    )
    parser.add_argument(
        '--pgbench-client', '-c',
        dest='pgbench_client',
        type=int,
        help="Number of pgbench clients. Default: %(default)s",
        default=64,
    )
    parser.add_argument(
        '--log-file',
        dest='log_file',
        type=str,
        help="TPS log file. Default: %(default)s",
        default='/tmp/tps.log',
    )

    env = parser.parse_args()

    try:
        conn = psycopg2.connect(env.pg)
        conn.set_session(autocommit=True)
    except psycopg2.Error as e:
        sys.exit("ERROR: Unable to connect to the database")

    pgbench_p = Process(
        target=pgbench,
        args=(env.pg_install_path, env.pg, env.duration, env.pgbench_client)
    )
    monitor_p = Process(
        target=monitor,
        args=(env.pg, env.log_file)
    )
    long_transaction_p = Process(
        target=long_transaction,
        args=(env.pg, env.duration)
    )

    # Starting processes
    monitor_p.start()
    long_transaction_p.start()
    pgbench_p.start()

    time.sleep(env.duration + 10)

    # Killing processes
    long_transaction_p.kill()
    pgbench_p.kill()
    monitor_p.kill()

    # Joining processes
    long_transaction_p.join()
    pgbench_p.join()
    monitor_p.join()
