#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import psycopg2
import time
from datetime import datetime as dt

def connect(conn_string):
    while True:
        try:
            #print("%s INFO: Connecting to PostgreSQL..." % dt.now())
            conn = psycopg2.connect(conn_string)
            #print("%s INFO: Connected." % dt.now())
            return conn
        except psycopg2.Error as e:
            print("%s ERROR: Cannot connect, new try." % dt.now())
            time.sleep(1)


def repl_lag_monitoring(conn, duration):
    starting_time = time.time()


    print("timestamp;application_name;sent_lag;write_lag;flush_lag;replay_lag")

    while (time.time() - starting_time < duration):
        time.sleep(1)
        cur = conn.cursor()
        cur.execute(
            "SELECT clock_timestamp(), application_name, "
            "pg_wal_lsn_diff(pg_current_wal_lsn(), sent_lsn) as sent_lag, "
            "pg_wal_lsn_diff(pg_current_wal_lsn(), write_lsn) as write_lag, "
            "pg_wal_lsn_diff(pg_current_wal_lsn(), flush_lsn) as flush_lag, "
            "pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) as replay_lag "
            "FROM pg_stat_replication "
            "ORDER BY application_name"
        )
        for r in cur.fetchall():
            print("%s;%s;%s;%s;%s;%s" % (r[0], r[1], r[2], r[3], r[4], r[5]))
        cur.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--pg',
        dest='pg',
        type=str,
        help="Postgres connection string to the primary node.",
        default='',
    )
    parser.add_argument(
        '--duration', '-d',
        dest='duration',
        type=int,
        help="Duration. Default: %(default)s",
        default=300,
    )
    env = parser.parse_args()

    conn = connect(env.pg)
    repl_lag_monitoring(conn, env.duration)
    conn.close()


if __name__ == '__main__':
    main()
