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


def wal_rate_monitoring(conn, duration):
    starting_time = time.time()

    cur = conn.cursor()
    cur.execute("SELECT clock_timestamp() AS now, pg_current_wal_lsn() AS current_lsn");
    r = cur.fetchone()
    prev_lsn = r[1]
    prev_time = r[0]
    cur.close()

    print("timestamp;lsn;wal_rate")

    while (time.time() - starting_time < duration):
        time.sleep(1)
        cur = conn.cursor()
        cur.execute(
            "SELECT clock_timestamp() as now, pg_current_wal_lsn() AS current_lsn, "
            "pg_wal_lsn_diff(pg_current_wal_lsn(), %s) AS wal_size",
            (prev_lsn,)
        )
        r = cur.fetchone()
        new_time = r[0]
        new_lsn = r[1]
        wal_rate = float(r[2]) / (new_time - prev_time).total_seconds()
        print("%s;%s;%s" % (new_time, new_lsn, wal_rate))
        prev_lsn = new_lsn
        prev_time = new_time
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
    wal_rate_monitoring(conn, env.duration)
    conn.close()


if __name__ == '__main__':
    main()
