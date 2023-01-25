# encoding: utf-8

# Script in charge of merging data points coming from different CSV files into
# one final document. This script is also responsible of generating charts
# using merged data.
# It requires pandas and matplot Python libraries.

import pandas as pd
import os
import re


def gen_nopm_rampup_chart(title, data_file, tde_data_file, dest_file):
    non_tde_data = pd.read_csv(data_file)
    non_tde_data.rename(columns={"nopm": "no-TDE"}, inplace=True)
    tde_data = pd.read_csv(tde_data_file)
    tde_data.rename(columns={"nopm": "TDE"}, inplace=True)

    data = pd.merge(non_tde_data, tde_data, on='vuser', how='inner')

    # Get vuser max value
    max_vuser = int(data.max()['vuser'])
    max_nopm = max(
        int(data.max()['no-TDE']),
        int(data.max()['TDE'])
    )

    # Generate the final chart
    plot = data.plot(
        x="vuser",
        figsize=(10, 6),
        grid=True,
        ylabel="NOPM",
        title=title,
        # Set Y limit to max_nopm + 10% of it
        ylim=(0, max_nopm + (max_nopm / 10)),
        xlim=(0, max_vuser),
    )
    fig = plot.get_figure()
    fig.savefig(dest_file)


def rewrite_cpu_sar_file(file):
    data = []
    with open(file, "r") as f:
        i = 0
        for line in f.readlines():
            i += 1
            # Ignore the first 2 lines
            if i < 3:
                continue
            data.append(re.split(r'\s{2,}', line.replace('\n', '')))
    # Remove the last line
    del(data[-1])

    # Save as CSV
    with open("%s.csv" % file, "w") as f:
        for row in data:
            f.write(",".join(row[2:-1]))
            f.write("\n")

    return "%s.csv" % file


def rewrite_mem_sar_file(file):
    data = []
    with open(file, "r") as f:
        i = 0
        for line in f.readlines():
            i += 1
            # Ignore the first 2 lines
            if i < 3:
                continue
            row = re.split(r'\s{1,}', line.replace('\n', ''))
            data.append(row)
    # Remove the last line
    del(data[-1])

    # Save as CSV
    with open("%s.csv" % file, "w") as f:
        for row in data:
            f.write(",".join(row[2:]))
            f.write("\n")

    return "%s.csv" % file


def rewrite_disk_sar_file(file, device, dest_file):
    data = []
    has_headers = False
    with open(file, "r") as f:
        i = 0
        for line in f.readlines():
            i += 1
            # Ignore the first 2 lines
            if i < 3:
                continue
            line = line.replace('\n', '')
            if len(line) == 0:
                continue
            row = re.split(r'\s{1,}', line)
            if has_headers and row[2] == 'DEV':
                continue
            if row[2] != device and row[2] != 'DEV':
                continue
            if row[2] == 'DEV':
                has_headers = True
            data.append(row)
    # Remove the last line
    del(data[-6:])

    # Save as CSV
    with open(dest_file, "w") as f:
        for row in data:
            f.write(",".join(row[2:]))
            f.write("\n")

    return dest_file


def gen_cpu_chart(title, data_file, dest_file):
    csv_file = rewrite_cpu_sar_file(data_file)
    data = pd.read_csv(csv_file)

    # Generate the final chart
    plot = data.plot.area(
        figsize=(10, 6),
        grid=True,
        ylabel="CPU (%)",
        title=title,
        stacked=True,
        ylim=(0, 100),
    )
    plot.tick_params(
        bottom=False,
        labelbottom=False,
    )
    fig = plot.get_figure()
    fig.savefig(dest_file)


def gen_mem_chart(title, data_file, tde_data_file, dest_file):
    csv_file = rewrite_mem_sar_file(data_file)
    tde_csv_file = rewrite_mem_sar_file(tde_data_file)

    data = pd.read_csv(csv_file)
    tde_data = pd.read_csv(tde_csv_file)

    # We only want to plot %memused for each case
    data.rename(columns={"%memused": "no-TDE"}, inplace=True)
    tde_data.rename(columns={"%memused": "TDE"}, inplace=True)

    memused_data = pd.merge(
        data[['no-TDE']],
        tde_data[['TDE']],
        left_index=True,
        right_index=True
    )
    # Generate the final chart
    plot = memused_data.plot(
        figsize=(10, 6),
        grid=True,
        ylabel="Mem. Used (%)",
        title=title,
        ylim=(0, 110),
    )
    plot.tick_params(
        bottom=False,
        labelbottom=False,
    )
    fig = plot.get_figure()
    fig.savefig(dest_file)


def gen_disk_charts(titles, data_file, tde_data_file, dest_files):
    dest_dir = os.path.dirname(dest_files[0])
    csv_pgdata_file = rewrite_disk_sar_file(data_file, 'VGPGDATA-LVPGDATA', '%s/sar-pgdata.csv' % dest_dir)
    csv_pgwal_file = rewrite_disk_sar_file(data_file, 'VGPGWAL-LVPGWAL', '%s/sar-pgwal.csv' % dest_dir)
    tde_csv_pgdata_file = rewrite_disk_sar_file(tde_data_file, 'VGPGDATA-LVPGDATA', '%s/sar-tde-pgdata.csv' % dest_dir)
    tde_csv_pgwal_file = rewrite_disk_sar_file(tde_data_file, 'VGPGWAL-LVPGWAL', '%s/sar-tde-pgwal.csv' % dest_dir)

    pgdata_data = pd.read_csv(csv_pgdata_file)
    tde_pgdata_data = pd.read_csv(tde_csv_pgdata_file)
    pgwal_data = pd.read_csv(csv_pgwal_file)
    tde_pgwal_data = pd.read_csv(tde_csv_pgwal_file)


    pgdata_data.rename(columns={"rkB/s": "no-TDE rkB/s", "wkB/s": "no-TDE wkB/s"}, inplace=True)
    pgwal_data.rename(columns={"rkB/s": "no-TDE rkB/s", "wkB/s": "no-TDE wkB/s"}, inplace=True)
    tde_pgdata_data.rename(columns={"rkB/s": "TDE rkB/s", "wkB/s": "TDE wkB/s"}, inplace=True)
    tde_pgwal_data.rename(columns={"rkB/s": "TDE rkB/s", "wkB/s": "TDE wkB/s"}, inplace=True)

    # PGDATA Write Throughput
    pgdata_w_throughput = pd.merge(
        pgdata_data[['no-TDE wkB/s']],
        tde_pgdata_data[['TDE wkB/s']],
        left_index=True,
        right_index=True
    )
    plot = pgdata_w_throughput.plot(
        figsize=(10, 6),
        grid=True,
        ylabel="kB/s",
        title=titles[0],
    )
    plot.tick_params(
        bottom=False,
        labelbottom=False,
    )
    fig = plot.get_figure()
    fig.savefig(dest_files[0])

    # PGDATA Read Throughput
    pgdata_r_throughput = pd.merge(
        pgdata_data[['no-TDE rkB/s']],
        tde_pgdata_data[['TDE rkB/s']],
        left_index=True,
        right_index=True
    )
    plot = pgdata_r_throughput.plot(
        figsize=(10, 6),
        grid=True,
        ylabel="kB/s",
        title=titles[1],
    )
    plot.tick_params(
        bottom=False,
        labelbottom=False,
    )
    fig = plot.get_figure()
    fig.savefig(dest_files[1])

    # PGWAL Write Throughput
    pgwal_w_throughput = pd.merge(
        pgwal_data[['no-TDE wkB/s']],
        tde_pgwal_data[['TDE wkB/s']],
        left_index=True,
        right_index=True
    )
    plot = pgwal_w_throughput.plot(
        figsize=(10, 6),
        grid=True,
        ylabel="kB/s",
        title=titles[2],
    )
    plot.tick_params(
        bottom=False,
        labelbottom=False,
    )
    fig = plot.get_figure()
    fig.savefig(dest_files[2])


def main():

    warehouse=2000
    duration=60
    vuser=75

    data_dir_path = os.path.dirname(os.path.realpath(__file__)) + "/benchmark_data"  # noqa
    gen_nopm_rampup_chart(
        title = "EPAS 15 - TDE vs no-TDE - NOPM vs virtual users (warehouse=%s)" % warehouse,  # noqa
        data_file="%s/nopm_rampup.csv" % data_dir_path,
        tde_data_file="%s/nopm_rampup_tde.csv" % data_dir_path,
        dest_file="%s/epas-15-tde-vs-no-tde-nopm-vs-vuser.png" % data_dir_path,
    )
    gen_cpu_chart(
        title="EPAS 15 - CPU usage - no-TDE (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
        data_file="%s/sar_cpu.txt" % data_dir_path,
        dest_file="%s/epas-15-no-tde-cpu.png" % data_dir_path,
    )
    gen_cpu_chart(
        title="EPAS 15 - CPU usage - TDE (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
        data_file="%s/sar_cpu_tde.txt" % data_dir_path,
        dest_file="%s/epas-15-tde-cpu.png" % data_dir_path,
    )
    gen_mem_chart(
        title = "EPAS 15 - TDE vs no-TDE - Mem. usage (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
        data_file="%s/sar_mem.txt" % data_dir_path,
        tde_data_file="%s/sar_mem_tde.txt" % data_dir_path,
        dest_file="%s/epas-15-tde-vs-no-tde-mem-usage.png" % data_dir_path,
    )
    gen_disk_charts(
        titles = [
            "EPAS 15 - TDE vs no-TDE - PGDATA Write throughput (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
            "EPAS 15 - TDE vs no-TDE - PGDATA Read throughput (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
            "EPAS 15 - TDE vs no-TDE - PGWAL Write throughput (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
        ],
        data_file="%s/sar_disk.txt" % data_dir_path,
        tde_data_file="%s/sar_disk_tde.txt" % data_dir_path,
        dest_files=[
            "%s/epas-15-tde-vs-no-tde-pgdata-w-throughput.png" % data_dir_path,
            "%s/epas-15-tde-vs-no-tde-pgdata-r-throughput.png" % data_dir_path,
            "%s/epas-15-tde-vs-no-tde-pgwal-w-throughput.png" % data_dir_path,
        ]
    )

if __name__ == '__main__':
    main()
