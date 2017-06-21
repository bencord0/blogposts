#!/usr/bin/env python3
from argparse import ArgumentParser
from datetime import datetime, timezone
from json import dumps


def main():
    parser = ArgumentParser()
    parser.add_argument('slug')
    parser.add_argument('title')

    args = parser.parse_args()
    now = datetime.utcnow().replace(
        microsecond=0, tzinfo=timezone.utc)

    print(dumps({
        'date': now.isoformat(),
        'slug': args.slug,
        'title': args.title,
    }, sort_keys=True))


if __name__ == '__main__':
    main()
