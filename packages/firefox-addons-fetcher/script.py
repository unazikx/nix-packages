#!/usr/bin/env python3

"""
Fetch Firefox addons from AMO API and generate a Nix expression.

Usage:
    python fetch_firefox_addons.py addons.json > addons.nix
    python fetch_firefox_addons.py addons.json -o addons.nix
"""

import json
import re
import sys
import hashlib
import traceback
import urllib.request
import urllib.error
import argparse
from typing import Any, Optional

AMO_API = "https://addons.mozilla.org/api/v5/addons/addon"


def fetch_json(url: str) -> dict:
    req = urllib.request.Request(
        url, headers={"User-Agent": "mozilla-addons-to-nix/1.0"}
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode())


def sha256_of_url(url: str) -> str:
    req = urllib.request.Request(
        url, headers={"User-Agent": "mozilla-addons-to-nix/1.0"}
    )
    h = hashlib.sha256()
    with urllib.request.urlopen(req, timeout=60) as resp:
        while chunk := resp.read(65536):
            h.update(chunk)
    return h.hexdigest()


def to_str(value: Any) -> str:
    """Recursively extract a plain string from any value (including nested locale dicts)."""
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        for key in ("en-US", "en", "en_US"):
            v = value.get(key)
            if v and isinstance(v, str):
                return v
        for v in value.values():
            if isinstance(v, str) and v:
                return v
            if isinstance(v, dict):
                result = to_str(v)
                if result:
                    return result
        return ""
    if isinstance(value, (int, float, bool)):
        return str(value)
    return ""


def strip_html(s: str) -> str:
    s = re.sub(r"<[^>]+>", "", s)
    s = (
        s.replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", '"')
        .replace("&#39;", "'")
        .replace("&nbsp;", " ")
    )
    return " ".join(s.split())


def nix_string(s: Any) -> str:
    s = to_str(s)
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("${", "\\${") + '"'


def nix_list(items: list, indent: int = 8) -> str:
    pad = " " * indent
    inner = "\n".join(f"{pad}  {nix_string(to_str(i))}" for i in items)
    return f"[\n{inner}\n{pad}]"


def get_description(data: dict) -> str:
    raw = to_str(data.get("summary")) or to_str(data.get("description"))
    return strip_html(raw)


def get_homepage(data: dict) -> str:
    return to_str(data.get("homepage"))


def get_permissions(data: dict) -> list:
    try:
        version = data["current_version"]
        file_info = version.get("file")
        if isinstance(file_info, dict):
            perms = file_info.get("permissions") or []
            if perms:
                return [to_str(p) for p in perms if to_str(p)]
        for f in version.get("files") or []:
            perms = f.get("permissions") or []
            if perms:
                return [to_str(p) for p in perms if to_str(p)]
    except (KeyError, TypeError, AttributeError):
        pass
    return []


def fetch_addon(slug: str) -> dict:
    url = f"{AMO_API}/{slug}/?lang=en-US"
    print(f"  Fetching metadata for {slug}", file=sys.stderr)
    data = fetch_json(url)

    if "--debug" in sys.argv:
        print(json.dumps(data, indent=2, ensure_ascii=False)[:3000], file=sys.stderr)

    pname = to_str(data.get("slug")) or slug
    addon_id = to_str(data.get("guid"))
    if not addon_id:
        raise ValueError(f"No GUID found for {slug}")

    version_data = data.get("current_version") or {}
    version = to_str(version_data.get("version"))
    if not version:
        raise ValueError(f"No version found for {slug}")

    download_url = ""
    file_info = version_data.get("file")
    if isinstance(file_info, dict):
        download_url = to_str(file_info.get("url"))
    if not download_url:
        for f in version_data.get("files") or []:
            u = to_str(f.get("url"))
            if u:
                download_url = u
                break

    if not download_url:
        raise ValueError(f"No download URL found for {slug}")

    print(f"  Downloading {slug} to compute sha256", file=sys.stderr)
    sha256 = sha256_of_url(download_url)

    homepage = get_homepage(data)
    description = get_description(data)
    permissions = get_permissions(data)

    return {
        "pname": pname,
        "version": version,
        "addonId": addon_id,
        "url": download_url,
        "sha256": sha256,
        "homepage": homepage,
        "description": description,
        "permissions": permissions,
    }


def render_addon(a: dict) -> str:
    lines = []
    lines.append(f'  {nix_string(a["pname"])} = buildFirefoxXpiAddon {{')
    lines.append(f'    pname = {nix_string(a["pname"])};')
    lines.append(f'    version = {nix_string(a["version"])};')
    lines.append(f'    addonId = {nix_string(a["addonId"])};')
    lines.append(f'    url = {nix_string(a["url"])};')
    lines.append(f'    sha256 = {nix_string(a["sha256"])};')
    lines.append(f"    meta = with lib; {{")
    if a["homepage"]:
        lines.append(f'      homepage = {nix_string(a["homepage"])};')
    if a["description"]:
        lines.append(f'      description = {nix_string(a["description"])};')
    if a["permissions"]:
        lines.append(f'      mozPermissions = {nix_list(a["permissions"])};')
    lines.append(f"      platforms = platforms.all;")
    lines.append(f"    }};")
    lines.append(f"  }};")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Generate Nix Firefox addon expressions from a JSON slug list."
    )
    parser.add_argument("input", help="JSON file with list of {slug} objects")
    parser.add_argument("-o", "--output", help="Output file (default: stdout)")
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Print full tracebacks and raw API data on errors",
    )
    args = parser.parse_args()

    with open(args.input) as f:
        slugs_data = json.load(f)

    slugs = [entry["slug"] for entry in slugs_data]

    addon_blocks = []
    errors = []
    for slug in slugs:
        try:
            addon = fetch_addon(slug)
            addon_blocks.append(render_addon(addon))
        except Exception as e:
            if args.debug:
                traceback.print_exc()
            print(f"  ERROR fetching {slug}: {e}", file=sys.stderr)
            errors.append(slug)

    nix_output = "{ buildFirefoxXpiAddon, lib }:\n{\n"
    nix_output += "\n".join(addon_blocks)
    nix_output += "\n}\n"

    if args.output:
        with open(args.output, "w") as f:
            f.write(nix_output)
        print(f"\nWrote output to {args.output}", file=sys.stderr)
    else:
        print(nix_output)

    if errors:
        print(f"\nFailed addons: {', '.join(errors)}", file=sys.stderr)


if __name__ == "__main__":
    main()
