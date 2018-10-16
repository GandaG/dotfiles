#!/usr/bin/env python

import feedparser
import os
import sqlite3
import stat
import tempfile

from pathlib import Path
from subprocess import run, PIPE

DB_PATH = Path(os.path.expandvars('$XDG_CACHE_HOME'), 'rss-sync.db')
URL_FILE = Path(os.path.expandvars('$XDG_CONFIG_HOME'), 'newsboat', 'urls')
NEW_ITEMS = {}


def expandshell(string):
    """Expands a string in a shell-like way, using expanduser and expandvars"""
    return os.path.expanduser(os.path.expandvars(string))


def make_executable(path):
    st = os.stat(path)
    os.chmod(path, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def notify(title, msg, icon=None):
    command = ['notify-send', title, msg]
    if icon is not None:
        command.extend(['-i', icon])
    return run(command, stdout=PIPE, stderr=PIPE).returncode == 0


def notify_new_items():
    global NEW_ITEMS

    title = "You have new unread articles!"
    body = ""
    filtered_dict = {k: v for k, v in NEW_ITEMS.items() if v}
    for key, value in filtered_dict.items():
        if len(value) == 1:
            body += "{} - {}\n".format(key, value[0])
        else:
            body += "{} - {} new articles\n".format(key, len(value))
    if body:
        notify(title, body)
    NEW_ITEMS = {}


def load_feed(url, script):
    if script is None:
        feed_src = url
    else:
        tmpf = tempfile.NamedTemporaryFile('w+t', delete=False)
        tmpf.write(script)
        tmpf.close()
        make_executable(tmpf.name)
        feed_src = run([tmpf.name, url], stdout=PIPE).stdout
        os.remove(tmpf.name)
    feed = feedparser.parse(feed_src)
    feed.href = feed.get('href', url)
    return feed


def init_db(conn):
    conn.executescript("""
            PRAGMA foreign_keys = ON;

            CREATE TABLE IF NOT EXISTS rss_feed(
                feed_url  VARCHAR(1024) PRIMARY KEY NOT NULL,
                url       VARCHAR(1024)             NOT NULL,
                title     VARCHAR(1024)             NOT NULL,
                script_id INTEGER                       NULL,
                FOREIGN KEY(script_id)
                    REFERENCES rss_script(id)
                    ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS rss_item(
                id       INTEGER        PRIMARY KEY AUTOINCREMENT,
                guid     VARCHAR(1024)  NOT NULL,
                title    VARCHAR(1024)  NOT NULL,
                url      VARCHAR(1024)  NOT NULL,
                feed_url VARCHAR(1024)  NOT NULL,
                FOREIGN KEY(feed_url)
                    REFERENCES rss_feed(feed_url)
                    ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS rss_script(
                id     INTEGER        PRIMARY KEY AUTOINCREMENT,
                script VARCHAR(65535) NOT NULL
            );

            CREATE UNIQUE INDEX IF NOT EXISTS idxFeed
                ON rss_feed(feed_url);

            CREATE INDEX IF NOT EXISTS idxItem
                ON rss_item(guid, url, feed_url);
            """)


def import_feeds_newsboat():
    with URL_FILE.open('rt') as urlf:
        feed_list = []
        for line in urlf:
            if line.startswith('"'):
                line = line[1:line.find('"', 1)]  # removes tags and quotes
            if line.startswith('exec:'):
                cmd = line[5:].split()
                with open(expandshell(cmd[0]), 'rt') as scriptf:
                    script = scriptf.read()
                feed_list.append((cmd[1], script))
            else:
                feed_list.append((line.strip(), None))
    return feed_list


def update_feeds(conn, imported_feeds):
    sql_query = """
        SELECT rss_feed.feed_url, rss_script.script
        FROM rss_feed
        LEFT JOIN rss_script ON rss_feed.script_id = rss_script.id;
        """
    self_feeds = conn.execute(sql_query).fetchall()
    feed_list = [load_feed(url, script) for url, script in self_feeds]

    self_set = set(self_feeds)
    import_set = set(imported_feeds)
    toadd = list(import_set - self_set)
    todel = list(self_set - import_set)

    sql_delete = "DELETE FROM rss_feed WHERE feed_url = ?;"
    conn.executemany(sql_delete, ((feed,) for feed, script in todel))
    after_del = self_set - (self_set - import_set)
    feed_list = [load_feed(url, script) for url, script in after_del]

    sql_add = """
        INSERT INTO rss_feed (feed_url, url, title, script_id)
        VALUES (?, ?, ?, ?);
        """
    sql_script = """
        INSERT INTO rss_script (script)
        VALUES (?);
        """
    for url, script in toadd:
        feed = load_feed(url, script)
        feed_list.append(feed)
        feed_url = feed.get('href', url)  # solves redirection issues
        link = feed.feed.get('link', url)
        title = feed.feed.title

        lastid = None
        if script is not None:
            cursor = conn.cursor()
            cursor.execute(sql_script, (script,))
            lastid = cursor.lastrowid
            cursor.close()
        conn.execute(sql_add, (feed_url, link, title, lastid))

    for feed in feed_list:
        NEW_ITEMS[feed.feed.title] = []
        update_items(conn, feed)


def update_items(conn, feed):
    sql_insert = """
            INSERT INTO rss_item
                (guid, title, url, feed_url)
            SELECT ?, ?, ?, ?
            WHERE NOT EXISTS(
                SELECT 1 FROM rss_item
                WHERE guid = ? AND url = ? AND feed_url = ?
            );
            """
    for entry in feed.entries:
        guid = entry.id
        title = entry.title
        url = entry.link
        feed_url = feed.href
        payload = (guid, title, url, feed_url, guid, url, feed_url)
        if conn.execute(sql_insert, payload).rowcount > 0:
            NEW_ITEMS[feed.feed.title].append(title)


def main():
    conn = sqlite3.connect(str(DB_PATH))
    try:
        init_db(conn)
        feed_list = import_feeds_newsboat()
        update_feeds(conn, feed_list)
        conn.commit()
    finally:
        conn.close()
    notify_new_items()


if __name__ == "__main__":
    main()
