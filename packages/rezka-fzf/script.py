#! /usr/bin/env python3

import aiohttp
import asyncio
import json
import os
import signal
import subprocess
import sys
import yaml
import re

from yaml.representer import SafeRepresenter
from concurrent.futures import ThreadPoolExecutor
from HdRezkaApi import HdRezkaSession

"""
HDRezka FZF - Terminal User Interface for HDRezka streaming service

Features:
    - Search and browse HDRezka content from terminal
    - Watch movies and series with various video players
    - Clean terminal interface built on fzf
    - Export all episode URLs for any quality
    - Favorites list with watched episode tracking
"""


def _represent_list(self, data):
    return self.represent_sequence("tag:yaml.org,2002:seq", data, flow_style=True)


SafeRepresenter.add_representer(list, _represent_list)


class Config:
    def __init__(self):
        xdg = os.getenv(
            "XDG_CONFIG_HOME", os.path.join(os.path.expanduser("~"), ".config")
        )
        self.config_dir = os.path.join(xdg, "rezka-fzf")
        self.config_path = os.path.join(self.config_dir, "config.yaml")
        self.favorites_path = os.path.join(self.config_dir, "favorites.yaml")
        self._cache = None
        self.setup_config()

    def setup_config(self):
        if not os.path.exists(self.config_path):
            print("First run setup\n")

            url = input("Enter HDRezka URL [https://hdrezka.ag]: ").strip()
            username = input("Username (optional): ").strip()
            password = input("Password (optional): ").strip()

            config_data = {
                "url": url or "https://hdrezka.ag",
                "username": username,
                "password": password,
                "player": "auto",
            }

            os.makedirs(self.config_dir, exist_ok=True)
            with open(self.config_path, "w") as f:
                yaml.dump(
                    config_data,
                    f,
                    allow_unicode=True,
                    default_flow_style=False,
                    indent=2,
                )

            print(f"\nConfiguration saved to: {self.config_path}\n")

    def load_auth_file(self, path: str):
        path = os.path.expanduser(path)
        if not os.path.exists(path):
            print(f"Auth file not found: {path}")
            sys.exit(1)

        with open(path) as f:
            lines = [l.strip() for l in f if l.strip() and not l.startswith("#")]

        data = {}
        for line in lines:
            if "=" in line:
                key, _, val = line.partition("=")
                key = key.strip().lower()
                val = val.strip()
                if key in ("username", "login", "email", "user"):
                    data["username"] = val
                elif key in ("password", "pass", "pwd"):
                    data["password"] = val
            else:
                if "username" not in data:
                    data["username"] = line
                elif "password" not in data:
                    data["password"] = line

        if "username" not in data or "password" not in data:
            print(
                "Auth file must contain username and password.\n"
                "Expected format:\n  username=...\n  password=...\nor two plain lines."
            )
            sys.exit(1)

        cache = self._load_cache()
        cache["username"] = data["username"]
        cache["password"] = data["password"]
        self._cache = cache

    def _load_cache(self):
        if self._cache is None:
            try:
                with open(self.config_path) as f:
                    self._cache = yaml.safe_load(f) or {}
            except (FileNotFoundError, yaml.YAMLError):
                self._cache = {}
        return self._cache

    def load(self, key, default=None):
        return self._load_cache().get(key, default)

    def load_favorites(self) -> list:
        if not os.path.exists(self.favorites_path):
            return []
        with open(self.favorites_path) as f:
            data = yaml.safe_load(f) or []
        return data if isinstance(data, list) else []

    def save_favorites(self, favs: list):
        os.makedirs(self.config_dir, exist_ok=True)
        with open(self.favorites_path, "w") as f:
            yaml.dump(favs, f, allow_unicode=True, default_flow_style=None)

    def find_favorite(self, item_id: int) -> dict | None:
        for fav in self.load_favorites():
            if fav.get("id") == item_id:
                return fav
        return None

    def add_favorite(
        self, item_id: int, content_type: str = None, url_short: str = None
    ):
        favs = self.load_favorites()
        for fav in favs:
            if fav.get("id") == item_id:
                return

        mirror = self.get_mirror()
        fav_item = {
            "id": item_id,
            "type": content_type,
            "url": f"{mirror}/{url_short}" if url_short else None,
            "url-short": url_short,
        }
        fav_item = {k: v for k, v in fav_item.items() if v is not None}

        favs.append(fav_item)
        self.save_favorites(favs)

    def remove_favorite(self, item_id: int):
        favs = [f for f in self.load_favorites() if f.get("id") != item_id]
        self.save_favorites(favs)

    def mark_watched(self, item_id: int, season: int, episode: int):
        favs = self.load_favorites()
        for fav in favs:
            if fav.get("id") == item_id:
                watched = fav.get("watched", {})
                if not isinstance(watched, dict):
                    watched = {}
                season_key = f"s{season}"
                eps = watched.get(season_key, [])
                if episode not in eps:
                    eps = sorted(set(eps) | {episode})
                watched[season_key] = eps
                fav["watched"] = watched
                self.save_favorites(favs)
                return

    def get_watched(self, item_id: int) -> dict:
        fav = self.find_favorite(item_id)
        if fav:
            return fav.get("watched", {})
        return {}

    def update_favorites_mirror(self):
        """Update all favorites URLs when mirror changes"""
        favs = self.load_favorites()
        if not favs:
            return

        mirror = self.get_mirror()
        changed = False

        for fav in favs:
            url_short = fav.get("url-short")
            if url_short:
                new_url = f"{mirror}/{url_short}"
                if fav.get("url") != new_url:
                    fav["url"] = new_url
                    changed = True

        if changed:
            self.save_favorites(favs)

    def get_mirror(self) -> str:
        """Get current mirror URL from config"""
        return self.load("url", "https://hdrezka.ag").rstrip("/")


class FzfSelector:
    def __init__(self):
        self.available = self._check_fzf()

    def _check_fzf(self):
        try:
            result = subprocess.run(["which", "fzf"], capture_output=True, timeout=1)
            return result.returncode == 0
        except Exception:
            return False

    async def select(self, items, prompt="Select", multi=False):
        if not self.available or not items:
            return None

        display_items = []
        value_map = {}

        for item in items:
            if isinstance(item, dict) and "display" in item:
                display = item["display"]
                value_map[display] = item.get("value", item)
            else:
                display = str(item)
                value_map[display] = item
            display_items.append(display)

        fzf_cmd = [
            "fzf",
            "--height=40%",
            "--layout=reverse",
            "--border=rounded",
            "--prompt=" + prompt + " > ",
            "--pointer=>",
            "--ansi",
            "--bind=esc:abort",
        ]

        if multi:
            fzf_cmd.append("--multi")

        try:
            loop = asyncio.get_event_loop()
            with ThreadPoolExecutor() as executor:
                process = await loop.run_in_executor(
                    executor,
                    lambda: subprocess.Popen(
                        fzf_cmd,
                        stdin=subprocess.PIPE,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        text=True,
                        env={**os.environ, "TERM": "xterm-256color"},
                    ),
                )

                input_text = "\n".join(display_items)
                stdout, _ = await loop.run_in_executor(
                    executor, process.communicate, input_text
                )

                if process.returncode != 0:
                    return None

                selected_displays = stdout.strip().split("\n")

                if multi:
                    return [value_map[d] for d in selected_displays if d in value_map]
                else:
                    return (
                        value_map.get(selected_displays[0])
                        if selected_displays[0]
                        else None
                    )

        except Exception:
            return None


class Player:
    def __init__(self, player_name=None):
        self.available_players = {
            "mpv": ["mpv", "--title={title}", "{url}"],
            "vlc": ["vlc", "{url}"],
            "celluloid": ["celluloid", "{url}"],
        }
        self.player_name = player_name or self._detect_player()

    def _detect_player(self):
        for player in ["mpv", "vlc", "celluloid"]:
            try:
                result = subprocess.run(
                    ["which", player], capture_output=True, timeout=1
                )
                if result.returncode == 0:
                    return player
            except Exception:
                continue
        return "mpv"

    def play(self, url, title=""):
        cmd_template = self.available_players.get(
            self.player_name, self.available_players["mpv"]
        )
        cmd = [arg.format(title=title, url=url) for arg in cmd_template]

        try:
            subprocess.Popen(
                cmd,
                start_new_session=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return True
        except Exception:
            return False


class HdRezkaApp:
    def __init__(
        self,
        auth_file: str = None,
        open_favorites: bool = False,
        direct_url: str = None,
    ):
        self.config = Config()
        if auth_file:
            self.config.load_auth_file(auth_file)
        self.open_favorites = open_favorites
        self.direct_url = direct_url
        self.session = None
        self.current_content = None
        self.current_item_id = None
        self.fzf = FzfSelector()
        self.player = Player(self.config.load("player"))
        self.executor = ThreadPoolExecutor(max_workers=4)

    async def setup(self):
        url = self.config.load("url", "https://hdrezka.ag")
        username = self.config.load("username", "")
        password = self.config.load("password", "")

        self.config.update_favorites_mirror()

        try:
            loop = asyncio.get_event_loop()
            self.session = await loop.run_in_executor(
                self.executor, lambda: HdRezkaSession(url)
            )
            if username and password:
                await loop.run_in_executor(
                    self.executor, lambda: self.session.login(username, password)
                )
            return True
        except Exception as e:
            print(f"Connection error: {e}")
            return False

    def _clean_text(self, s: str | None) -> str:
        if not isinstance(s, str):
            return ""
        s = re.sub(r"[\r\n\t]", "", s)
        return s.strip()

    async def get_search_query(self):
        try:
            print("Search (Ctrl-C to exit): ", end="", flush=True)
            loop = asyncio.get_event_loop()
            query = await loop.run_in_executor(self.executor, sys.stdin.readline)
            return query.strip()
        except (KeyboardInterrupt, EOFError):
            return None

    async def search_and_select(self):
        query = await self.get_search_query()
        if not query:
            return None

        try:
            loop = asyncio.get_event_loop()
            search_obj = await loop.run_in_executor(
                self.executor, lambda: self.session.search(query, find_all=True)
            )
            results = []

            try:
                for page in search_obj:
                    if isinstance(page, list):
                        results.extend(page)
                    else:
                        results.append(page)
                    if len(results) >= 50:
                        break
            except StopIteration:
                pass

            if not results:
                print("No results found")
                return None

            favorites = self.config.load_favorites()
            fav_ids = {fav.get("id") for fav in favorites}

            result_items = []
            for item in results:
                title = self._clean_text(item.get("title", ""))
                item_id = self._extract_id(item.get("url", ""))

                fav_mark = "!!! " if item_id in fav_ids else ""

                extras = []
                if "year" in item:
                    extras.append(str(item["year"]))
                if "type" in item:
                    content_type = (
                        item["type"].replace("format.", "").replace("_", " ").title()
                    )
                    extras.append(content_type)

                id_str = f"[{item_id}] " if item_id else ""
                display = f"{fav_mark}{id_str}{title}" + (
                    f" ({', '.join(extras)})" if extras else ""
                )
                result_items.append({"display": display, "value": item})

            return await self.fzf.select(result_items, prompt="Select Content")

        except Exception as e:
            print(f"Search error: {e}")
            return None

    async def browse_favorites(self):
        favs = self.config.load_favorites()
        if not favs:
            print("No favorites yet...")
            return None

        items = []
        for fav in favs:
            fav_id = fav.get("id")
            fav_type = fav.get("type", "")
            type_str = f" [{fav_type}]" if fav_type else ""
            url_short = fav.get("url-short", "")
            url_str = f" ({url_short})" if url_short else ""

            watched = fav.get("watched", {})
            watched_str = ""
            if watched:
                parts = []
                for sk in sorted(watched.keys()):
                    eps = watched[sk]
                    parts.append(f"{sk}:{','.join(str(e) for e in eps)}")
                watched_str = f"  ✓ {' '.join(parts)}"

            display = f"ID: {fav_id}{type_str}{url_str}{watched_str}"
            items.append({"display": display, "value": fav})

        items.append({"display": "── Remove from favorites ──", "value": "__remove__"})

        selected = await self.fzf.select(items, prompt="Favorites")
        if selected is None:
            return None

        if selected == "__remove__":
            await self.remove_favorite_menu(favs)
            return None

        url_short = selected.get("url-short")
        if url_short:
            mirror = self.config.get_mirror()
            url = f"{mirror}/{url_short}"
        else:
            fav_id = selected.get("id")
            url = f"https://hdrezka.ag/{fav_id}"

        item = {"url": url}
        return item, selected.get("id")

    async def remove_favorite_menu(self, favs):
        items = [
            {"display": f"ID: {f.get('id')} [{f.get('type', 'unknown')}]", "value": f}
            for f in favs
        ]
        selected = await self.fzf.select(items, prompt="Remove")
        if selected:
            self.config.remove_favorite(selected.get("id"))
            print(f"\033[33m✗\033[0m Removed ID {selected.get('id')} from favorites")

    def _extract_id(self, url: str) -> int | None:
        try:
            slug = url.rstrip("/").split("/")[-1]
            part = slug.split("-")[0]
            if part.isdigit():
                return int(part)
        except Exception:
            pass
        return None

    async def load_content(self, item, item_id=None):
        try:
            loop = asyncio.get_event_loop()
            slug = item["url"].rstrip("/").split("/")[-1]
            self.current_content = await loop.run_in_executor(
                self.executor, lambda: self.session.get(slug)
            )
            if self.current_content is None:
                return False
            self.current_item_id = item_id or self._extract_id(item.get("url", ""))
            self.current_slug = slug
            return True
        except Exception as e:
            print(f"Error loading content: {e}")
            self.current_content = None
            return False

    async def is_series(self):
        try:
            if hasattr(self.current_content, "seriesInfo"):
                try:
                    loop = asyncio.get_event_loop()
                    series_info = await loop.run_in_executor(
                        self.executor, lambda: self.current_content.seriesInfo
                    )
                    if series_info is not None:
                        return True
                except Exception:
                    pass

            if hasattr(self.current_content, "episodesInfo"):
                try:
                    loop = asyncio.get_event_loop()
                    episodes = await loop.run_in_executor(
                        self.executor, lambda: self.current_content.episodesInfo
                    )
                    if episodes and len(episodes) > 0:
                        return True
                except Exception:
                    pass

            if hasattr(self.current_content, "type"):
                try:
                    content_type = str(self.current_content.type).lower()
                    if any(x in content_type for x in ["series", "tvshow", "сериал"]):
                        return True
                except Exception:
                    pass

            return False
        except Exception:
            return False

    async def get_movie_translations(self):
        translations = []

        try:
            if (
                hasattr(self.current_content, "translators_names")
                and self.current_content.translators_names
            ):
                for name, data in self.current_content.translators_names.items():
                    premium = " [PREMIUM]" if data.get("premium", False) else ""
                    translations.append(
                        {
                            "display": f"{name}{premium}",
                            "value": data["id"],
                            "name": name,
                        }
                    )
                return translations

            if (
                hasattr(self.current_content, "translators")
                and self.current_content.translators
            ):
                for trans_id, data in self.current_content.translators.items():
                    name = data.get("name", "Unknown")
                    premium = " [PREMIUM]" if data.get("premium", False) else ""
                    translations.append(
                        {"display": f"{name}{premium}", "value": trans_id, "name": name}
                    )
                return translations

            return translations
        except Exception as e:
            print(f"Error getting translations: {e}")
            return translations

    async def get_series_translations(self, season_num, episode_num):
        translations = []

        try:
            if hasattr(self.current_content, "episodesInfo"):
                try:
                    episodes_info = self.current_content.episodesInfo
                    for season in episodes_info:
                        if season["season"] == season_num:
                            for episode in season["episodes"]:
                                if episode["episode"] == episode_num:
                                    for trans in episode.get("translations", []):
                                        name = trans.get("translator_name", "Unknown")
                                        premium = (
                                            " [PREMIUM]"
                                            if trans.get("premium", False)
                                            else ""
                                        )
                                        translations.append(
                                            {
                                                "display": f"{name}{premium}",
                                                "value": trans.get("translator_id"),
                                                "name": name,
                                            }
                                        )
                                    break
                            break
                except Exception:
                    pass

            if not translations and hasattr(self.current_content, "translators"):
                for tid, tdata in self.current_content.translators.items():
                    name = tdata.get("name", "Unknown")
                    premium = " [PREMIUM]" if tdata.get("premium", False) else ""
                    translations.append(
                        {"display": f"{name}{premium}", "value": tid, "name": name}
                    )

            return translations
        except Exception as e:
            print(f"Error getting series translations: {e}")
            return translations

    async def _select_translator(self, season=None, episode=None):
        is_series_content = await self.is_series()

        if is_series_content and season is not None and episode is not None:
            translations = await self.get_series_translations(season, episode)
        else:
            translations = await self.get_movie_translations()

        if not translations:
            return None, None

        if len(translations) == 1:
            t = translations[0]
            return t["value"], t.get("name", "unknown")

        prompt = "Select Translation"
        if season and episode:
            prompt = f"S{season}E{episode} Translation"

        selected = await self.fzf.select(translations, prompt=prompt)
        if selected is None:
            return None, None

        if isinstance(selected, dict):
            return selected.get("value"), selected.get("name", "unknown")
        return selected, "unknown"

    async def _get_stream_object(self, season=None, episode=None, translator_id=None):
        loop = asyncio.get_event_loop()
        if await self.is_series() and season is not None and episode is not None:
            return await loop.run_in_executor(
                self.executor,
                lambda: self.current_content.getStream(
                    season=season,
                    episode=str(episode),
                    translation=translator_id,
                ),
            )
        if translator_id:
            return await loop.run_in_executor(
                self.executor,
                lambda: self.current_content.getStream(translation=translator_id),
            )
        return await loop.run_in_executor(
            self.executor, lambda: self.current_content.getStream()
        )

    async def _get_available_qualities(self, stream):
        try:
            videos = stream.videos
            if isinstance(videos, dict) and videos:
                order = ["2160p", "1080p Ultra", "1080p", "720p", "480p", "360p"]
                available = [q for q in order if q in videos]
                for q in videos:
                    if q not in available:
                        available.append(q)
                return available
        except Exception:
            pass
        return []

    def _safe_name(self, s):
        return s.replace("/", "_").replace("\\", "_").replace(" ", "_")

    async def show_content_menu(self):
        content = self.current_content
        content_type = "Series" if await self.is_series() else "Movie"
        item_id = self.current_item_id
        in_favorites = (
            self.config.find_favorite(item_id) is not None if item_id else False
        )

        menu_items = []
        menu_items.append({"display": "Watch", "value": "watch"})

        if in_favorites:
            menu_items.append(
                {"display": "Remove from favorites", "value": "fav_remove"}
            )
        else:
            menu_items.append({"display": "Add to favorites", "value": "fav_add"})

        if await self.is_series():
            menu_items.append(
                {"display": "Export all episode URLs to file", "value": "export_urls"}
            )
        else:
            menu_items.append(
                {"display": "Export movie URLs to file", "value": "export_movie_urls"}
            )

        if hasattr(content, "otherParts") and content.otherParts:
            menu_items.append(
                {
                    "display": f"Other Parts ({len(content.otherParts)} available)",
                    "value": "other_parts",
                }
            )

        menu_items.append({"display": "━━━ Info ━━━", "value": None})

        id_str = f" [{item_id}]" if item_id else ""
        title = self._clean_text(content.name)
        orig = self._clean_text(content.origName)

        menu_items.append({"display": f"Title: {title}{id_str}", "value": None})
        menu_items.append({"display": f"Original: {orig}", "value": None})

        if hasattr(content, "description") and content.description:
            desc_raw = self._clean_text(content.description)
            desc = (desc_raw[:150] + "…") if len(desc_raw) > 150 else desc_raw
            menu_items.append({"display": f"Description: {desc}", "value": None})

        menu_items.extend(
            [
                {"display": f"Year: {content.releaseYear}", "value": None},
                {"display": f"Type: {content_type}", "value": None},
                {"display": f"Rating: {content.rating}", "value": None},
            ]
        )

        if in_favorites and await self.is_series() and item_id:
            watched = self.config.get_watched(item_id)
            if watched:
                for sk in sorted(watched.keys()):
                    eps = watched[sk]
                    ep_str = ", ".join(str(e) for e in eps)
                    menu_items.append(
                        {"display": f"Watched {sk}: episodes {ep_str}", "value": None}
                    )

        return await self.fzf.select(menu_items, prompt=f"{content_type} Menu")

    async def handle_other_parts(self):
        parts = self.current_content.otherParts
        if not parts:
            return False

        parts_items = []
        for part in parts:
            for name, url in part.items():
                parts_items.append({"display": name, "value": url})

        selected_url = await self.fzf.select(parts_items, prompt="Select Part")

        if selected_url:
            try:
                loop = asyncio.get_event_loop()
                self.current_content = await loop.run_in_executor(
                    self.executor,
                    lambda: self.session.get(selected_url.rstrip("/").split("/")[-1]),
                )
                self.current_item_id = self._extract_id(selected_url)
                return True
            except Exception:
                return False
        return False

    async def select_episode(self):
        try:
            episodes_info = None

            if hasattr(self.current_content, "episodesInfo"):
                try:
                    episodes_info = self.current_content.episodesInfo
                except Exception:
                    pass

            if not episodes_info and hasattr(self.current_content, "seriesInfo"):
                try:
                    series_info = self.current_content.seriesInfo
                    if series_info and isinstance(series_info, dict):
                        episodes_info = []
                        for season_num, episodes in series_info.items():
                            if isinstance(episodes, (list, tuple)):
                                episode_list = []
                                for ep_num in episodes:
                                    episode_list.append(
                                        {
                                            "episode": (
                                                int(ep_num)
                                                if str(ep_num).isdigit()
                                                else ep_num
                                            ),
                                            "translations": [],
                                        }
                                    )
                                episodes_info.append(
                                    {
                                        "season": (
                                            int(season_num)
                                            if str(season_num).isdigit()
                                            else season_num
                                        ),
                                        "episodes": episode_list,
                                    }
                                )
                except Exception:
                    pass

            if not episodes_info:
                print("This content doesn't have episodes")
                return None, None

            watched = {}
            if self.current_item_id:
                watched = self.config.get_watched(self.current_item_id)

            if len(episodes_info) == 1:
                season = episodes_info[0]
            else:
                season_items = []
                for s in episodes_info:
                    if isinstance(s, dict) and s.get("episodes"):
                        sn = s.get("season", "?")
                        watched_eps = watched.get(f"s{sn}", [])
                        total = len(s["episodes"])
                        w_str = (
                            f" ✓{len(watched_eps)}/{total}"
                            if watched_eps
                            else f" {total} ep"
                        )
                        display = f"Season {sn}{w_str}"
                        season_items.append({"display": display, "value": s})

                if not season_items:
                    print("No seasons available")
                    return None, None

                season = await self.fzf.select(season_items, prompt="Season")
                if not season:
                    return None, None

            season_num = season.get("season")
            if season_num is None:
                print("Invalid season data")
                return None, None

            episodes = season.get("episodes", [])
            if not episodes:
                print(f"No episodes for season {season_num}")
                return None, None

            watched_eps = watched.get(f"s{season_num}", [])

            episode_items = []
            for e in episodes:
                ep_num = e.get("episode")
                if ep_num:
                    w_mark = " ✓" if ep_num in watched_eps else ""
                    episode_items.append(
                        {"display": f"Episode {ep_num}{w_mark}", "value": e}
                    )

            if not episode_items:
                print("No episodes available")
                return None, None

            episode = await self.fzf.select(
                episode_items, prompt=f"S{season_num} Episode"
            )
            if not episode:
                return None, None

            episode_num = episode.get("episode")
            return season_num, episode_num

        except Exception as e:
            print(f"Error selecting episode: {e}")
            return None, None

    async def _get_all_episodes(self):
        episodes_info = None
        try:
            if hasattr(self.current_content, "episodesInfo"):
                episodes_info = self.current_content.episodesInfo
        except Exception:
            pass

        if not episodes_info and hasattr(self.current_content, "seriesInfo"):
            try:
                series_info = self.current_content.seriesInfo
                if series_info and isinstance(series_info, dict):
                    episodes_info = []
                    for season_num, episodes in series_info.items():
                        if isinstance(episodes, (list, tuple)):
                            episodes_info.append(
                                {
                                    "season": (
                                        int(season_num)
                                        if str(season_num).isdigit()
                                        else season_num
                                    ),
                                    "episodes": [
                                        {"episode": int(e) if str(e).isdigit() else e}
                                        for e in episodes
                                    ],
                                }
                            )
            except Exception:
                pass

        if not episodes_info:
            return []

        return [
            (s["season"], e["episode"])
            for s in episodes_info
            for e in s.get("episodes", [])
            if s.get("season") is not None and e.get("episode") is not None
        ]

    async def export_all_urls(self):
        translator_id, translator_name = await self._select_translator()
        if translator_id is None and await self.get_movie_translations():
            return

        all_eps = await self._get_all_episodes()
        if not all_eps:
            return

        try:
            test_stream = await self._get_stream_object(
                all_eps[0][0], all_eps[0][1], translator_id
            )
            qualities = await self._get_available_qualities(test_stream)
        except Exception as ex:
            print(f"Error: {ex}")
            return

        if not qualities:
            return

        quality = await self.fzf.select(
            [{"display": q, "value": q} for q in qualities],
            prompt="Quality for export",
        )
        if not quality:
            return

        title = self._clean_text(self.current_content.name)
        results = {}
        for s, e in all_eps:
            try:
                stream = await self._get_stream_object(s, e, translator_id)
                urls = stream.videos.get(quality, [])
                if not isinstance(urls, list):
                    urls = [urls]
            except Exception as ex:
                urls = [f"ERROR: {ex}"]
            results.setdefault(s, []).append((e, urls))

        safe_title = self._safe_name(title)
        safe_quality = self._safe_name(quality)
        safe_translator = self._safe_name(translator_name or "unknown")
        filename = f"{safe_title}_{safe_quality}_{safe_translator}_urls.txt"

        with open(filename, "w") as f:
            f.write(f"{title} — {quality} — {translator_name}\n")
            f.write("=" * 60 + "\n\n")
            for sn in sorted(results.keys()):
                f.write(f"Season {sn}\n")
                f.write("-" * 40 + "\n")
                for en, urls in sorted(results[sn], key=lambda x: x[0]):
                    f.write(f"\nS{sn:02d}E{en:02d}\n")
                    for i, url in enumerate(urls, 1):
                        prefix = f"  [{i}] " if len(urls) > 1 else "  "
                        f.write(f"{prefix}{url}\n")
                f.write("\n")

        print(
            f"\033[32m✓\033[0m {len(all_eps)} episodes ({quality}) → \033[1m{filename}\033[0m"
        )

    async def export_movie_urls(self):
        translator_id, translator_name = await self._select_translator()
        if translator_id is None and await self.get_movie_translations():
            return

        try:
            stream = await self._get_stream_object(translator_id=translator_id)
            qualities = await self._get_available_qualities(stream)
        except Exception as ex:
            print(f"Error: {ex}")
            return

        if not qualities:
            return

        quality = await self.fzf.select(
            [{"display": q, "value": q} for q in qualities],
            prompt="Quality for export",
        )
        if not quality:
            return

        title = self._clean_text(self.current_content.name)
        safe_title = self._safe_name(title)
        safe_quality = self._safe_name(quality)
        safe_translator = self._safe_name(translator_name or "unknown")
        filename = f"{safe_title}_{safe_quality}_{safe_translator}_urls.txt"

        try:
            urls = stream.videos.get(quality, [])
            if not isinstance(urls, list):
                urls = [urls]
        except Exception as ex:
            print(f"Error getting URLs: {ex}")
            return

        with open(filename, "w") as f:
            f.write(f"{title} — {quality} — {translator_name}\n")
            f.write("=" * 60 + "\n\n")
            for i, url in enumerate(urls, 1):
                prefix = f"[{i}] " if len(urls) > 1 else ""
                f.write(f"{prefix}{url}\n")

        print(f"\033[32m✓\033[0m {title} ({quality}) → \033[1m{filename}\033[0m")

    async def play_content(self, season=None, episode=None):
        try:
            is_series_content = False
            try:
                is_series_content = await self.is_series()
            except Exception:
                is_series_content = season is not None and episode is not None

            stream = None
            for attempt in range(3):
                try:
                    translator_id, _ = await self._select_translator(season, episode)
                    if translator_id is None:
                        translations = (
                            await self.get_series_translations(season, episode)
                            if is_series_content
                            else await self.get_movie_translations()
                        )
                        if translations:
                            return

                    stream = await self._get_stream_object(
                        season, episode, translator_id
                    )
                    break

                except UnicodeDecodeError:
                    if attempt == 2:
                        print("Failed after 3 attempts")
                        return
                    print(f"Decode error, retrying ({attempt+1}/3)")
                    continue
                except Exception as e:
                    print(f"Error getting stream: {e}")
                    return

            if stream is None:
                return

            available = await self._get_available_qualities(stream)
            if not available:
                print("No qualities available")
                return

            quality_items = [{"display": q, "value": q} for q in available]
            quality = await self.fzf.select(quality_items, prompt="Quality")
            if not quality:
                return

            try:
                urls = stream.videos.get(quality, [])
                if not isinstance(urls, list):
                    urls = [urls]
            except Exception:
                raw = stream(quality)
                if isinstance(raw, bytes):
                    raw = raw.decode(errors="ignore")
                if isinstance(raw, str):
                    urls = json.loads(raw) if raw.strip().startswith("[") else [raw]
                elif isinstance(raw, list):
                    urls = raw
                else:
                    urls = [str(raw)]

            if not urls:
                print("No URLs available for selected quality")
                return

            if len(urls) == 1:
                url = urls[0]
            else:
                url_items = [{"display": str(u)[:132], "value": u} for u in urls]
                url = await self.fzf.select(url_items, prompt="Select Mirror")

            if url:
                title = self._clean_text(self.current_content.name)
                if season and episode:
                    title += f" S{season}E{episode}"
                self.player.play(url, title)

                if (
                    season
                    and episode
                    and self.current_item_id
                    and self.config.find_favorite(self.current_item_id)
                ):
                    self.config.mark_watched(self.current_item_id, season, episode)

        except Exception as e:
            print(f"Playback error: {e}")

    async def run(self):
        if not await self.setup():
            return

        if not self.fzf.available:
            print("fzf not found. Please install fzf")
            return

        if self.direct_url:
            item_id = self._extract_id(self.direct_url)

            if not self.direct_url.startswith("http"):
                slug = self.direct_url
            else:
                slug = self.direct_url.rstrip("/").split("/")[-1]

            item = {"url": f"https://hdrezka.ag/{slug}"}

            if await self.load_content(item, item_id):
                if self.current_content is None:
                    print("Failed to load content")
                    return

                while True:
                    action = await self.show_content_menu()

                    if action is None:
                        break

                    if action == "fav_add":
                        if self.current_item_id:
                            content_type = (
                                "series" if await self.is_series() else "movie"
                            )
                            self.config.add_favorite(
                                self.current_item_id, content_type, self.current_slug
                            )
                            print("★ Added to favorites")
                        continue

                    if action == "fav_remove":
                        if self.current_item_id:
                            self.config.remove_favorite(self.current_item_id)
                            print("✗ Removed from favorites")
                        continue

                    if action == "other_parts":
                        await self.handle_other_parts()
                        continue

                    if action == "export_urls":
                        await self.export_all_urls()
                        continue

                    if action == "export_movie_urls":
                        await self.export_movie_urls()
                        continue

                    if action == "watch":
                        if await self.is_series():
                            season, episode = await self.select_episode()
                            if season and episode:
                                await self.play_content(season, episode)
                        else:
                            await self.play_content()
            return

        def sigint_handler(sig, frame):
            print("\nGoodbye!")
            sys.exit(0)

        signal.signal(signal.SIGINT, sigint_handler)

        while True:
            try:
                item = None
                item_id = None

                if self.open_favorites:
                    self.open_favorites = False
                    result = await self.browse_favorites()
                    if result is None:
                        continue
                    item, item_id = result
                else:
                    item = await self.search_and_select()
                    if item is None:
                        choice = await self.fzf.select(
                            [
                                {"display": "Open favorites", "value": "favs"},
                                {"display": "Exit", "value": "exit"},
                            ],
                            prompt="",
                        )
                        if choice == "favs":
                            result = await self.browse_favorites()
                            if result is None:
                                continue
                            item, item_id = result
                        else:
                            break
                        continue

                if item is None:
                    continue

                if not await self.load_content(item, item_id):
                    continue

                while True:
                    action = await self.show_content_menu()

                    if action is None:
                        break

                    if action == "fav_add":
                        if self.current_item_id:
                            content_type = (
                                "series" if await self.is_series() else "movie"
                            )
                            self.config.add_favorite(
                                self.current_item_id, content_type, self.current_slug
                            )
                            print("★ Added to favorites")
                        continue

                    if action == "fav_remove":
                        if self.current_item_id:
                            self.config.remove_favorite(self.current_item_id)
                            print("✗ Removed from favorites")
                        continue

                    if action == "other_parts":
                        await self.handle_other_parts()
                        continue

                    if action == "export_urls":
                        await self.export_all_urls()
                        continue

                    if action == "export_movie_urls":
                        await self.export_movie_urls()
                        continue

                    if action == "watch":
                        if await self.is_series():
                            season, episode = await self.select_episode()
                            if season and episode:
                                await self.play_content(season, episode)
                        else:
                            await self.play_content()

            except KeyboardInterrupt:
                print("\nGoodbye!")
                break
            except Exception as e:
                print(f"Error: {e}")
                continue

        self.executor.shutdown(wait=True)


def main():
    import argparse

    parser = argparse.ArgumentParser(
        prog="rezka-fzf",
        description="HDRezka terminal UI built on fzf",
    )
    parser.add_argument(
        "--authFile",
        metavar="PATH",
        help="Path to a file containing username and password "
        "(plain lines or key=value format).",
    )
    parser.add_argument(
        "--favorites",
        action="store_true",
        help="Open favorites list on startup.",
    )
    parser.add_argument(
        "--url",
        metavar="URL_OR_ID",
        help="Open content directly by URL or ID (e.g., 'https://hdrezka.ag/434365-pantheon.html' or '434365').",
    )
    args = parser.parse_args()

    app = HdRezkaApp(
        auth_file=args.authFile, open_favorites=args.favorites, direct_url=args.url
    )
    asyncio.run(app.run())


if __name__ == "__main__":
    main()
