#!/usr/bin/env python3

import click
import gi

gi.require_version('Gdk', '3.0')

from gi.repository import Gdk

screen = Gdk.Display.get_default()
geo = Gdk.Monitor.get_geometry(screen.get_primary_monitor())


@click.command()
@click.option('-w', is_flag=True, help='primary monitor\'s width')
@click.option('-h', is_flag=True, help='primary monitor\'s height')
def size(w=False, h=False):
    if w and h or not w and not h:
        click.echo(str(geo.width) + 'x' + str(geo.height))
    elif w:
        click.echo(geo.width)
    elif h:
        click.echo(geo.height)


if __name__ == '__main__':
    size()
