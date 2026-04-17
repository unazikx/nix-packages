#!/usr/bin/env python3

import argparse, os, subprocess, sys
from pathlib import Path


def find_java(pkg: str) -> Path | None:
    store = Path("/nix/store")
    if not store.exists():
        return None
    matches = sorted(store.glob(f"*{pkg}*"))
    for d in reversed(matches):
        java = d / "bin" / "java"
        if java.exists() and os.access(java, os.X_OK):
            return java
    return None


p = argparse.ArgumentParser(prog="portablemc-jvm")
p.add_argument("--jre", help="JRE package substring (e.g. temurin-jre-bin-21)")
p.add_argument("args", nargs=argparse.REMAINDER)
opts = p.parse_args()

cmd = ["portablemc"] + opts.args
if opts.jre:
    java = find_java(opts.jre)
    if not java:
        print(f"error: '{opts.jre}' not found in /nix/store", file=sys.stderr)
        sys.exit(1)
    if opts.args:
        cmd = ["portablemc", opts.args[0], "--jvm", str(java)] + opts.args[1:]

sys.exit(subprocess.run(cmd).returncode)
