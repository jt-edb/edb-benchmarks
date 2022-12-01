# encoding: utf-8

# Script in charge of merging data points coming from different CSV files into
# one final document. This script is also responsible of generating a chart
# using merged data.
# It requires pandas and matplot Python libraries.

import pandas as pd
import os

def main():
    pg_versions = os.getenv('PG_VERSIONS', '')
    pgbench_scale_factor = os.getenv('PGBENCH_SCALE_FACTOR')

    dir_path = os.path.dirname(os.path.realpath(__file__))

    # PG_VERSIONS is passed using the following form: '[x, y, z]'. Which is
    # actually a string, so we need to transform it into a real python list.
    pg_versions = pg_versions.replace('[','').replace(']','').split(', ')

    all_data = None
    max_tps = 0

    for pg_version in pg_versions:
        pg_version = pg_version.strip('\'').strip('\"')
        data = pd.read_csv(
            '%s/pgbench_data/pgbench-tps-%s.csv' % (dir_path, pg_version)
        )
        # Max TPS value
        max_current_tps = data.max()[1]
        if max_current_tps > max_tps:
            max_tps = max_current_tps

        if all_data is None:
            all_data = data
        else:
            # Joining data using the clients column
            all_data = pd.merge(all_data, data, on='clients', how='inner');

    # Save the final CSV file
    all_data.to_csv(
        '%s/pgbench_data/pgbench-tps-all.csv' % dir_path, index=False
    )

    # Get clients max value
    max_clients = int(all_data.max()['clients'])

    # Generate the final chart
    plot = all_data.plot(
        x="clients",
        figsize=(10, 6),
        grid=True,
        ylabel="TPS",
        title="TPC-B-like (pgbench) TPS rate with scalefactor=%s" % pgbench_scale_factor,  # noqa
        # Set Y limit to max_tps + 10% of it
        ylim=(0, max_tps + (max_tps / 10)),
        xlim=(0, max_clients),
    )
    fig = plot.get_figure()
    fig.savefig('%s/pgbench_data/pgbench-tps-all.png' % dir_path)

if __name__ == '__main__':
    main()
