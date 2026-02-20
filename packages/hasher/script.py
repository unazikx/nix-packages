#!/usr/bin/env python3

# u can insert absolute, home dir and ../ types of path
#
# ./hash_nix.py ./pack.toml
# ./hash_nix.py https://raw.githubusercontent.com/azikxz/assets/refs/heads/main/mods-configs/pack.toml

import sys
import hashlib
import base64
import os


def hash_file(path):
    with open(path, "rb") as f:
        data = f.read()
    h = hashlib.sha256(data).digest()
    print("sha256-" + base64.b64encode(h).decode())


def hash_url(url):
    import urllib.request

    with urllib.request.urlopen(url) as r:
        data = r.read()
    h = hashlib.sha256(data).digest()
    print("sha256-" + base64.b64encode(h).decode())


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <file_or_url>")
        sys.exit(1)
    arg = sys.argv[1]
    if arg.startswith("http://") or arg.startswith("https://"):
        hash_url(arg)
    elif os.path.isfile(arg):
        hash_file(arg)
    else:
        print("Error: not a valid file or URL")
        sys.exit(1)


if __name__ == "__main__":
    main()
