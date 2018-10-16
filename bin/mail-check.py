#!/usr/bin/env python

import email
import time
from email.header import decode_header, make_header
from email.utils import parseaddr
from pathlib import Path
from subprocess import run, PIPE
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

MAILDIR = Path(Path.home(), '.mail', 'gmail', 'Inbox', 'new')


def notify(title, msg, icon=None):
    command = ['notify-send', title, msg]
    if icon is not None:
        command.extend(['-i', icon])
    return run(command, stdout=PIPE, stderr=PIPE).returncode == 0


def decode(header):
    return str(make_header(decode_header(header)))


def parse_mail(path):
    with open(path, 'rt') as fp:
        msg = email.message_from_file(fp)
    sender = parseaddr(decode(msg['From']))[0]
    subject = decode(msg['Subject'])
    notify('You have new mail!', '{} - {}'.format(sender, subject))


class Handler(FileSystemEventHandler):

    @staticmethod
    def on_created(event):
        if event.is_directory:
            return None
        parse_mail(event.src_path)


class Watcher:
    DIRECTORY_TO_WATCH = str(MAILDIR)

    def __init__(self):
        self.observer = Observer()

    def run(self):
        event_handler = Handler()
        self.observer.schedule(event_handler, self.DIRECTORY_TO_WATCH)
        self.observer.start()
        try:
            while True:
                time.sleep(5)
        except KeyboardInterrupt:
            self.observer.stop()
        self.observer.join()


if __name__ == '__main__':
    for path in MAILDIR.glob('*'):
        if path.is_dir():
            continue
        parse_mail(str(path))
    w = Watcher()
    w.run()
