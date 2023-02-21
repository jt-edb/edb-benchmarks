# encoding: utf-8

# Script in charge of extracting and drawing chart of relevant data coming from
# the time command output.
# It requires the matplot Python library.

import matplotlib.pyplot as plt
import os
import re


def extract_time_data(data_file):
    user_time = None
    system_time = None
    cpu_percent = None
    elapsed_time = None
    with open(data_file) as f:
        for line in f.readlines():
            m = re.search(r'User time \(seconds\): ([0-9\.]+)$', line)
            if m:
                user_time = m.group(1)
                continue
            m = re.search(r'System time \(seconds\): ([0-9\.]+)$', line)
            if m:
                system_time = m.group(1)
                continue
            m = re.search(r'Percent of CPU this job got: ([0-9]+)%$', line)
            if m:
                cpu_percent = m.group(1)
                continue
            m = re.search(r'Elapsed \(wall clock\) time.*: ([0-9\.:]+)$', line)
            if m:
                elapsed_time = m.group(1)
                continue
    return (user_time, system_time, cpu_percent, elapsed_time)


def gen_cpu_time_chart(system_data, user_data, dest):
    x = ['no-TDE', 'TDE']
    fig, ax = plt.subplots()
    ax.bar(x, system_data)
    ax.bar(x, user_data, bottom=system_data)
    ax.set_ylabel("CPU time (s)")
    ax.legend(["System time", "User time"])
    ax.set_title("System and user CPU time (s)")
    i = 0
    for x, y in zip(x, user_data):
        y = y + system_data[i]
        label = "{:.2f} s".format(y)
        ax.annotate(
            label,
            (x, y),
            textcoords="offset points",
            xytext=(0, 2),
            ha='center',
            color='black'
        )
        i += 1
    fig.savefig(dest)


def gen_cpu_percentage(cpu_percent, tde_cpu_percent, dest):
    fig, ax = plt.subplots()
    data = [cpu_percent, tde_cpu_percent]
    x = ['no-TDE', 'TDE']
    ax.bar(x, data)
    ax.set_ylabel("CPU usage (%)")
    ax.set_ylim([0, 100])
    ax.set_title("CPU usage (%)")
    for x, y in zip(x, data):
        label = "{:.2f} %".format(y)
        ax.annotate(
            label,
            (x, y),
            textcoords="offset points",
            xytext=(0, 2),
            ha='center',
            color='black'
        )
    fig.savefig(dest)


def gen_elapsed_time(elapsed_time, tde_elapsed_time, dest):
    fig, ax = plt.subplots()
    data = [elapsed_time, tde_elapsed_time]
    x = ['no-TDE', 'TDE']
    ax.bar(x, data)
    ax.set_ylim([0, max(data) + max(data) * 10 / 100])
    ax.set_ylabel("time (s)")
    ax.set_title("Elapsed time (s)")
    for x, y in zip(x, data):
        label = "{:.2f} s".format(y)
        ax.annotate(
            label,
            (x, y),
            textcoords="offset points",
            xytext=(0, 2),
            ha='center',
            color='black'
        )
    fig.savefig(dest)


def get_sec(time_str):
    m, s = time_str.split(':')
    return int(m) * 60 + float(s)


def main():
    data_dir_path = os.path.dirname(os.path.realpath(__file__)) + "/benchmark_data"  # noqa
    (user_time, system_time, cpu_percent, elapsed_time) \
        = extract_time_data("%s/time_pg_upgrade.output" % data_dir_path)
    (tde_user_time, tde_system_time, tde_cpu_percent, tde_elapsed_time) \
        = extract_time_data("%s/time_pg_upgrade_tde.output" % data_dir_path)

    gen_cpu_time_chart(
        [float(system_time), float(tde_system_time)],
        [float(user_time), float(tde_user_time)],
        "%s/system-user-cpu-time.png" % data_dir_path
    )
    gen_cpu_percentage(
        float(cpu_percent),
        float(tde_cpu_percent),
        "%s/cpu-percentage.png" % data_dir_path
    )
    gen_elapsed_time(
        get_sec(elapsed_time),
        get_sec(tde_elapsed_time),
        "%s/elapsed-time.png" % data_dir_path
    )


if __name__ == '__main__':
    main()
