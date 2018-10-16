#!/usr/bin/env python3

import i3

from os.path import expandvars
from subprocess import run, PIPE


SIZE_EXE = expandvars('$LOCAL_BIN/screen-size.py')
SIZE_CMD = ['python', SIZE_EXE]
SIZE_H = int(run(SIZE_CMD + ['-h'], stdout=PIPE, encoding='utf8').stdout)
SIZE_W = int(run(SIZE_CMD + ['-w'], stdout=PIPE, encoding='utf8').stdout)
WIDTH = round(SIZE_W * .95)
HEIGHT = round(SIZE_H * .85)


def find_tmp():
    tmps = i3.filter(nodes=[], window=None, name=None)
    if len(tmps) != 1:
        return None
    return tmps[0]['id']


def create_tmp(current_id):
    i3.focus(con_id=current_id)
    i3.split('vertical')
    i3.open()


def destroy_tmp(tmp_id):
    i3.kill(con_id=tmp_id)


def make_float(current_id):
    i3.focus(con_id=current_id)
    i3.floating('enable')
    i3.resize('set ' + str(WIDTH) + ' ' + str(HEIGHT))
    i3.move('position center')


def make_unfloat(current_id):
    i3.focus(con_id=current_id)
    i3.floating('disable')


def main():
    current = i3.filter(nodes=[], focused=True)[0]
    print(current)
    current_id = current['id']
    if "on" in current['floating']:
        tmp_id = find_tmp()
        if tmp_id is not None:
            i3.focus(con_id=tmp_id)
            make_unfloat(current_id)
            destroy_tmp(tmp_id)
        else:
            make_unfloat()
    else:
        if find_tmp() is None:
            create_tmp(current_id)
            make_float(current_id)


if __name__ == "__main__":
    main()
