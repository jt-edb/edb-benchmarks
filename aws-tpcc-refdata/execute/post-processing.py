# encoding: utf-8

# Script in charge of merging data points coming from different CSV files into
# one final document. This script is also responsible of generating charts
# using merged data.
# It requires pandas and matplot Python libraries.

import pandas as pd
import os
import re


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
    dev_col_number = 1
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

            # Handle the case when the timestamp includes PM or AM
            # In this case, the column containing device names is the next one
            if row[dev_col_number] in ['AM', 'PM']:
                dev_col_number = 2

            if has_headers and row[dev_col_number] == 'DEV':
                continue
            if row[dev_col_number] != device and row[dev_col_number] != 'DEV':
                continue
            if row[dev_col_number] == 'DEV':
                has_headers = True
            data.append(row)
    # Remove the last line
    del(data[-6:])

    # Save as CSV
    with open(dest_file, "w") as f:
        for row in data:
            f.write(",".join(row[dev_col_number:]))
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


def gen_mem_chart(title, data_file, refdata_data_file, dest_file):
    csv_file = rewrite_mem_sar_file(data_file)
    refdata_csv_file = rewrite_mem_sar_file(refdata_data_file)

    data = pd.read_csv(csv_file)
    refdata_data = pd.read_csv(refdata_csv_file)

    # We only want to plot %memused for each case
    data.rename(columns={"%memused": "heap"}, inplace=True)
    refdata_data.rename(columns={"%memused": "refdata"}, inplace=True)

    memused_data = pd.merge(
        data[['heap']],
        refdata_data[['refdata']],
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


def gen_disk_charts(titles, data_file, refdata_data_file, dest_files):
    dest_dir = os.path.dirname(dest_files[0])
    csv_pgdata_file = rewrite_disk_sar_file(data_file, 'VGPGDATA-LVPGDATA', '%s/sar-pgdata.csv' % dest_dir)
    csv_pgwal_file = rewrite_disk_sar_file(data_file, 'VGPGWAL-LVPGWAL', '%s/sar-pgwal.csv' % dest_dir)
    refdata_csv_pgdata_file = rewrite_disk_sar_file(refdata_data_file, 'VGPGDATA-LVPGDATA', '%s/sar-refdata-pgdata.csv' % dest_dir)
    refdata_csv_pgwal_file = rewrite_disk_sar_file(refdata_data_file, 'VGPGWAL-LVPGWAL', '%s/sar-refdata-pgwal.csv' % dest_dir)

    pgdata_data = pd.read_csv(csv_pgdata_file)
    refdata_pgdata_data = pd.read_csv(refdata_csv_pgdata_file)
    pgwal_data = pd.read_csv(csv_pgwal_file)
    refdata_pgwal_data = pd.read_csv(refdata_csv_pgwal_file)


    pgdata_data.rename(columns={"rkB/s": "heap rkB/s", "wkB/s": "heap wkB/s"}, inplace=True)
    pgwal_data.rename(columns={"rkB/s": "heap rkB/s", "wkB/s": "heap wkB/s"}, inplace=True)
    refdata_pgdata_data.rename(columns={"rkB/s": "refdata rkB/s", "wkB/s": "refdata wkB/s"}, inplace=True)
    refdata_pgwal_data.rename(columns={"rkB/s": "refdata rkB/s", "wkB/s": "refdata wkB/s"}, inplace=True)

    # PGDATA Write Throughput
    pgdata_w_throughput = pd.merge(
        pgdata_data[['heap wkB/s']],
        refdata_pgdata_data[['refdata wkB/s']],
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
        pgdata_data[['heap rkB/s']],
        refdata_pgdata_data[['refdata rkB/s']],
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
        pgwal_data[['heap wkB/s']],
        refdata_pgwal_data[['refdata wkB/s']],
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
    gen_cpu_chart(
        title="PostgreSQL 15 - heap - CPU usage (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
        data_file="%s/sar_cpu.txt" % data_dir_path,
        dest_file="%s/pg-15-heap-cpu.png" % data_dir_path,
    )
    gen_cpu_chart(
        title="PostgreSQL 15 - refdata - CPU usage (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
        data_file="%s/sar_cpu_refdata.txt" % data_dir_path,
        dest_file="%s/pg-15-refdata-cpu.png" % data_dir_path,
    )
    gen_mem_chart(
        title = "PostgreSQL 15 - refdata vs heap - Mem. usage (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
        data_file="%s/sar_mem.txt" % data_dir_path,
        refdata_data_file="%s/sar_mem_refdata.txt" % data_dir_path,
        dest_file="%s/pg-15-refdata-vs-heap-mem-usage.png" % data_dir_path,
    )
    gen_disk_charts(
        titles = [
            "PostgreSQL 15 - refdata vs heap - PGDATA Write throughput (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
            "PostgreSQL 15 - refdata vs heap - PGDATA Read throughput (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
            "PostgreSQL 15 - refdata vs heap - PGWAL Write throughput (duration=%s min, warehouse=%s, vuser=%s)" % (duration, warehouse, vuser),  # noqa
        ],
        data_file="%s/sar_disk.txt" % data_dir_path,
        refdata_data_file="%s/sar_disk_refdata.txt" % data_dir_path,
        dest_files=[
            "%s/pg-15-refdata-vs-heap-pgdata-w-throughput.png" % data_dir_path,
            "%s/pg-15-refdata-vs-heap-pgdata-r-throughput.png" % data_dir_path,
            "%s/pg-15-refdata-vs-heap-pgwal-w-throughput.png" % data_dir_path,
        ]
    )

if __name__ == '__main__':
    main()
