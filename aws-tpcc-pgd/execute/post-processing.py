# encoding: utf-8

# Script in charge of plotting NOPM vs catchup_time over vusers
# It requires pandas and matplot Python libraries.

import pandas as pd
import matplotlib.pyplot as plt
import os
import re


def gen_nopm_catchup_time_chart(title, data_file, dest_file):
    data = pd.read_csv(data_file)
    data.rename(columns={"nopm": "NOPM"}, inplace=True)
    data.rename(columns={"catchup_time": "Catchup Time (s)"}, inplace=True)

    # Get vuser max value
    max_vuser = int(data.max()['vuser'])
    max_nopm = int(data.max()['NOPM'])
    max_catchup_time = int(data.max()['Catchup Time (s)'])

    fig, ax = plt.subplots(figsize=(10, 6))

    data.plot(
        x='vuser',
        y='NOPM',
        ax=ax,
        grid=True,
        ylabel="NOPM",
        title=title,
        # Set Y limit to max_nopm + 10% of it
        ylim=(0, max_nopm + (max_nopm / 10)),
        xlim=(0, max_vuser),
    )
    data.plot(
        x='vuser',
        y='Catchup Time (s)',
        ax=ax,
        grid=False,
        ylabel="seconds",
        title=title,
        # Set Y limit to max_nopm + 10% of it
        ylim=(0, max_catchup_time + (max_catchup_time / 10)),
        xlim=(0, max_vuser),
        secondary_y=True,
    )

    fig.savefig(dest_file)


def main():
    data_dir_path = os.path.dirname(os.path.realpath(__file__)) + "/benchmark_data"  # noqa
    gen_nopm_catchup_time_chart(
        title = "TPROC-C NOPM vs replication catchup time",
        data_file="%s/pgd_nopm_catchup_time.csv" % data_dir_path,
        dest_file="%s/pgd-nopm-catchup-time.png" % data_dir_path,
    )

if __name__ == '__main__':
    main()
