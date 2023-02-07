# coding: utf-8

import argparse
from pathlib import Path, PurePath
import os
import sys
import yaml

from jinja2 import Environment, FileSystemLoader


def render_template(template_name, vars={}):

    current_dir = Path(__file__).parent.resolve()
    templates_dir = PurePath.joinpath(current_dir, 'templates')

    file_loader = FileSystemLoader(str(templates_dir))
    env = Environment(loader=file_loader, trim_blocks=True)
    template = env.get_template(template_name)

    return template.render(**vars)


def template(template_name, dest, vars={}):
    try:
        content = render_template(template_name + '.j2', vars)
        with open(dest, 'w') as f:
            f.write(content)
    except Exception as e:
        sys.exit("ERROR: could not render template %s (%s)"
                 % (template_name, e))


def load_yaml(file_path):
    if not os.path.exists(file_path):
        sys.exit("ERROR: file %s not found" % file_path)
    try:
        with open(file_path) as f:
            return yaml.load(f.read(), Loader=yaml.CLoader)
    except Exception as e:
        sys.exit("ERROR: could not read file %s (%s)" % (file_path, e))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'project_path',
        metavar='PROJECT_PATH',
        type=Path,
        help="Project path.",
    )
    parser.add_argument(
        '--dest',
        metavar='DEST_DIR',
        type=Path,
        help="Inventory destination directory.",
        required=False,
        default=Path(__file__).parent.resolve(),
    )
    env = parser.parse_args()

    servers = load_yaml(env.project_path / 'servers.yml')
    inventory_vardict = dict(
        servers = servers['servers']['machines'],
    )
    # Build the inventory file
    template('inventory.yml', env.dest / 'inventory.yml', inventory_vardict)
