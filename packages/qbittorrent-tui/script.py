#!/usr/bin/env python3

"""
qbitui - tui client for qbittorrent,
it is not standalone client,
created for qbittorrent-nox...

requirements: requests urwid
"""

import urwid
import requests
import time
import os
import sys
import json
from pathlib import Path
from typing import List, Dict, Optional


class Config:
    """Управление конфигурацией"""

    def __init__(self, config_path: str = "~/.qbtui.json"):
        self.config_path = Path(config_path).expanduser()
        self.config = self.load()

    def load(self) -> Dict:
        """Загрузить конфигурацию из файла"""
        if self.config_path.exists():
            try:
                with open(self.config_path, "r") as f:
                    return json.load(f)
            except:
                return {}
        return {}

    def save(self, config: Dict):
        """Сохранить конфигурацию в файл"""
        self.config_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.config_path, "w") as f:
            json.dump(config, f, indent=2)

    def get(self, key: str, default=None):
        """Получить значение из конфига"""
        return self.config.get(key, default)


class QBitAPI:
    """API клиент для qBittorrent (аналог qbt CLI)"""

    def __init__(self, host: str, port: int, username: str, password: str):
        self.base_url = f"http://{host}:{port}/api/v2"
        self.session = requests.Session()
        self.username = username
        self.password = password
        self.authenticated = False

    def login(self) -> bool:
        """Авторизация в qBittorrent"""
        try:
            response = self.session.post(
                f"{self.base_url}/auth/login",
                data={"username": self.username, "password": self.password},
                timeout=5,
            )
            self.authenticated = response.text == "Ok."
            return self.authenticated
        except requests.exceptions.Timeout:
            print("✗ Connection timeout")
            return False
        except requests.exceptions.ConnectionError:
            print("✗ Connection refused")
            return False
        except Exception as e:
            print(f"✗ Error: {e}")
            return False

    def get_torrents(
        self, filter_state: Optional[str] = None, category: Optional[str] = None
    ) -> List[Dict]:
        """Получить список торрентов (qbt torrent list)"""
        if not self.authenticated:
            return []
        try:
            params = {}
            if filter_state:
                params["filter"] = filter_state
            if category:
                params["category"] = category
            response = self.session.get(
                f"{self.base_url}/torrents/info", params=params, timeout=5
            )
            return response.json()
        except:
            return []

    def get_categories(self) -> Dict:
        """Получить категории (qbt category list)"""
        try:
            response = self.session.get(
                f"{self.base_url}/torrents/categories", timeout=5
            )
            return response.json()
        except:
            return {}

    def get_tags(self) -> List[str]:
        """Получить теги (qbt tag list)"""
        try:
            response = self.session.get(f"{self.base_url}/torrents/tags", timeout=5)
            return response.json()
        except:
            return []

    def pause_torrent(self, torrent_hash: str):
        """Приостановить торрент (qbt torrent pause)"""
        self.session.post(
            f"{self.base_url}/torrents/pause", data={"hashes": torrent_hash}, timeout=5
        )

    def resume_torrent(self, torrent_hash: str):
        """Возобновить торрент (qbt torrent resume)"""
        self.session.post(
            f"{self.base_url}/torrents/resume", data={"hashes": torrent_hash}, timeout=5
        )

    def pause_all(self):
        """Приостановить все (qbt torrent pause --all)"""
        self.session.post(
            f"{self.base_url}/torrents/pause", data={"hashes": "all"}, timeout=5
        )

    def resume_all(self):
        """Возобновить все (qbt torrent resume --all)"""
        self.session.post(
            f"{self.base_url}/torrents/resume", data={"hashes": "all"}, timeout=5
        )

    def delete_torrent(self, torrent_hash: str, delete_files: bool = False):
        """Удалить торрент (qbt torrent delete)"""
        self.session.post(
            f"{self.base_url}/torrents/delete",
            data={"hashes": torrent_hash, "deleteFiles": str(delete_files).lower()},
            timeout=5,
        )

    def recheck_torrent(self, torrent_hash: str):
        """Перепроверить торрент (qbt torrent recheck)"""
        self.session.post(
            f"{self.base_url}/torrents/recheck",
            data={"hashes": torrent_hash},
            timeout=5,
        )

    def reannounce_torrent(self, torrent_hash: str):
        """Переанонсировать торрент (qbt torrent reannounce)"""
        self.session.post(
            f"{self.base_url}/torrents/reannounce",
            data={"hashes": torrent_hash},
            timeout=5,
        )

    def set_category(self, torrent_hash: str, category: str):
        """Установить категорию (qbt torrent category set)"""
        self.session.post(
            f"{self.base_url}/torrents/setCategory",
            data={"hashes": torrent_hash, "category": category},
            timeout=5,
        )

    def add_category(self, category: str, save_path: str = ""):
        """Добавить категорию (qbt category add)"""
        self.session.post(
            f"{self.base_url}/torrents/createCategory",
            data={"category": category, "savePath": save_path},
            timeout=5,
        )

    def add_torrent_url(
        self, url: str, category: str = "", paused: bool = False, save_path: str = ""
    ):
        """Добавить торрент по URL/magnet (qbt torrent add url)"""
        data = {"urls": url}
        if category:
            data["category"] = category
        if paused:
            data["paused"] = "true"
        if save_path:
            data["savepath"] = save_path
        self.session.post(f"{self.base_url}/torrents/add", data=data, timeout=10)

    def add_torrent_file(
        self,
        filepath: str,
        category: str = "",
        paused: bool = False,
        save_path: str = "",
    ):
        """Добавить торрент из файла (qbt torrent add file)"""
        try:
            with open(filepath, "rb") as f:
                files = {"torrents": f}
                data = {}
                if category:
                    data["category"] = category
                if paused:
                    data["paused"] = "true"
                if save_path:
                    data["savepath"] = save_path
                self.session.post(
                    f"{self.base_url}/torrents/add", files=files, data=data, timeout=10
                )
                return True
        except Exception as e:
            return False

    def set_speed_limit(
        self, torrent_hash: str, download_limit: int = 0, upload_limit: int = 0
    ):
        """Установить лимиты скорости (qbt torrent limit)"""
        if download_limit >= 0:
            self.session.post(
                f"{self.base_url}/torrents/setDownloadLimit",
                data={"hashes": torrent_hash, "limit": download_limit},
                timeout=5,
            )
        if upload_limit >= 0:
            self.session.post(
                f"{self.base_url}/torrents/setUploadLimit",
                data={"hashes": torrent_hash, "limit": upload_limit},
                timeout=5,
            )

    def set_location(self, torrent_hash: str, location: str):
        """Установить путь сохранения (qbt torrent location set)"""
        self.session.post(
            f"{self.base_url}/torrents/setLocation",
            data={"hashes": torrent_hash, "location": location},
            timeout=5,
        )

    def get_properties(self, torrent_hash: str) -> Dict:
        """Получить свойства торрента (qbt torrent properties)"""
        try:
            response = self.session.get(
                f"{self.base_url}/torrents/properties",
                params={"hash": torrent_hash},
                timeout=5,
            )
            return response.json()
        except:
            return {}

    def get_magnet_link(self, torrent_hash: str) -> str:
        """Получить magnet ссылку"""
        try:
            props = self.get_properties(torrent_hash)
            magnet = props.get("magnet_uri", "")
            if not magnet:
                info_hash = props.get("hash", torrent_hash)
                name = props.get("name", "")
                trackers_response = self.session.get(
                    f"{self.base_url}/torrents/trackers",
                    params={"hash": torrent_hash},
                    timeout=5,
                )
                trackers = trackers_response.json()
                tracker_urls = [
                    t["url"]
                    for t in trackers
                    if t.get("url")
                    and t["url"] != "** [DHT] **"
                    and t["url"] != "** [PeX] **"
                    and t["url"] != "** [LSD] **"
                ]

                if tracker_urls:
                    magnet = f"magnet:?xt=urn:btih:{info_hash}"
                    if name:
                        magnet += f"&dn={name}"
                    for tr in tracker_urls[:5]:
                        magnet += f"&tr={tr}"
                    return magnet
            return magnet
        except:
            return ""


class TorrentLine(urwid.WidgetWrap):
    """Одна строка торрента в стиле Torque"""

    def __init__(
        self, index: int, torrent: Dict, selected: bool = False, term_width: int = 120
    ):
        self.torrent = torrent
        self.index = index

        name = torrent.get("name", "Unknown")
        state = torrent.get("state", "unknown")
        progress = torrent.get("progress", 0) * 100
        size = torrent.get("size", 0)
        downloaded = torrent.get("downloaded", 0)
        dlspeed = torrent.get("dlspeed", 0)
        upspeed = torrent.get("upspeed", 0)
        eta = torrent.get("eta", 0)

        status_icon = self._get_status_icon(state, progress)
        size_str = self._format_size(size)
        dl_str = self._format_speed(dlspeed)
        up_str = self._format_speed(upspeed)
        eta_str = self._format_eta(eta)

        # Вычисление доступной ширины для имени
        max_name_len = max(30, term_width - 20)

        if len(name) > max_name_len:
            name = name[: max_name_len - 3] + "..."

        # Первая строка - номер, иконка и название
        line1 = f"{index:>3}: {status_icon} {name}"

        # Вторая строка - статистика с отступом
        line2 = f"     ⇣ {dl_str:>9}/s | ⇡ {up_str:>9}/s | {size_str:>10} | {progress:>5.1f}% ETA: ({eta_str})"

        # Объединяем строки
        full_text = f"{line1}\n{line2}"

        if selected:
            widget = urwid.AttrMap(urwid.Text(full_text), "selected")
        else:
            widget = urwid.Text(full_text)

        super().__init__(widget)

    def _get_status_icon(self, state: str, progress: float) -> str:
        """Иконка статуса"""
        if progress >= 100:
            return "✓"
        elif state in ["downloading", "metaDL", "forcedDL"]:
            return "↓"
        elif state in ["uploading", "stalledUP", "forcedUP"]:
            return "↑"
        elif state in ["pausedDL", "pausedUP"]:
            return "||"
        elif state in ["queuedDL", "queuedUP"]:
            return "⋯"
        elif state in ["checkingDL", "checkingUP", "checkingResumeData"]:
            return "⟳"
        elif state in ["error", "missingFiles", "unknown"]:
            return "✗"
        else:
            return "◦"

    def _format_eta(self, eta: int) -> str:
        """Форматировать ETA"""
        if eta == 8640000 or eta < 0:
            return "∞"
        if eta == 0:
            return "Done"

        hours = eta // 3600
        minutes = (eta % 3600) // 60
        seconds = eta % 60

        if hours > 24:
            days = hours // 24
            return f"{days}d {hours % 24}h"
        elif hours > 0:
            return f"{hours}h {minutes}m"
        elif minutes > 0:
            return f"{minutes}m {seconds}s"
        else:
            return f"{seconds}s"

    def _format_size(self, bytes_size: int) -> str:
        """Форматировать размер"""
        if bytes_size == 0:
            return "0 MB"

        for unit in ["B", "KB", "MB", "GB", "TB"]:
            if abs(bytes_size) < 1024.0:
                if unit in ["B", "KB"]:
                    return f"{bytes_size:.0f} {unit}"
                return f"{bytes_size:.1f} {unit}"
            bytes_size /= 1024.0
        return f"{bytes_size:.1f} PB"

    def _format_speed(self, speed: int) -> str:
        """Форматировать скорость (в MB/s)"""
        if speed == 0:
            return "0.0"
        speed_mb = speed / (1024 * 1024)
        if speed_mb >= 1:
            return f"{speed_mb:.1f}"
        speed_kb = speed / 1024
        return f"{speed_kb:.1f}"


class QBitTUI:
    """Главное приложение TUI"""

    def __init__(self, api: QBitAPI):
        self.api = api
        self.selected_index = 0
        self.torrents = []
        self.filter_state = None
        self.show_footer = False
        self.sort_by = "ratio"
        self.sort_reverse = False

        self.palette = [
            # element , fg, bg
            ("selected", "black", "light red"),
            ("footer", "light gray", "black"),
        ]

        self.torrent_list = urwid.SimpleFocusListWalker([])
        self.listbox = urwid.ListBox(self.torrent_list)

        self.footer = urwid.AttrMap(
            urwid.Text(
                " [j/k] scroll [s]tart [p]ause [r]emove [a]dd [q]uit", align="left"
            ),
            "footer",
        )

        self.frame = urwid.Frame(body=self.listbox)
        self.loop = urwid.MainLoop(
            self.frame, palette=self.palette, unhandled_input=self.handle_input
        )
        self.loop.set_alarm_in(2, self.update_torrents)

    def sort_torrents(self):
        """Сортировать список торрентов"""
        sort_keys = {
            "name": lambda t: t.get("name", "").lower(),
            "size": lambda t: t.get("size", 0),
            "progress": lambda t: t.get("progress", 0),
            "dlspeed": lambda t: t.get("dlspeed", 0),
            "upspeed": lambda t: t.get("upspeed", 0),
            "added_on": lambda t: t.get("added_on", 0),
            "ratio": lambda t: t.get("ratio", 0),
        }

        if self.sort_by in sort_keys:
            self.torrents.sort(key=sort_keys[self.sort_by], reverse=self.sort_reverse)

    def show_sort_dialog(self):
        """Диалог сортировки"""

        def set_sort(button, sort_key):
            if self.sort_by == sort_key:
                self.sort_reverse = not self.sort_reverse
            else:
                self.sort_by = sort_key
                self.sort_reverse = True
            self.loop.widget = self.frame
            self.update_torrents()

        sorts = [
            ("Name", "name"),
            ("Size", "size"),
            ("Progress", "progress"),
            ("Download Speed", "dlspeed"),
            ("Upload Speed", "upspeed"),
            ("Date Added", "added_on"),
            ("Ratio", "ratio"),
        ]

        buttons = []
        for label, value in sorts:
            indicator = "→ " if self.sort_by == value else "  "
            direction = "↓" if self.sort_reverse else "↑"
            display = f"{indicator}{label} {direction if self.sort_by == value else ''}"
            btn = urwid.Button(display, set_sort, value)
            buttons.append(urwid.AttrMap(btn, None, focus_map="selected"))

        pile = urwid.Pile(
            [
                urwid.Divider(),
                urwid.Text("Sort by (click again to reverse)", align="center"),
                urwid.Divider(),
            ]
            + buttons
            + [urwid.Divider()]
        )

        box = urwid.LineBox(urwid.Filler(pile, valign="top"))
        overlay = urwid.Overlay(box, self.frame, "center", 40, "middle", 16)
        self.loop.widget = overlay

    def update_torrents(self, loop=None, user_data=None):
        """Обновить список торрентов"""
        self.torrents = self.api.get_torrents(self.filter_state)
        self.sort_torrents()  # Добавь эту строку
        self.refresh_list()

        # Обновление футера со счетчиком
        total = len(self.torrents)
        current = self.selected_index + 1 if self.torrents else 0
        footer_text = f" [j/k]scroll [space] [r]m [a]dd [t]sort [o]pts [?] [q]uit ({current}/{total})"
        self.footer.original_widget.set_text(footer_text)

        # Обновить отображение футера
        if self.show_footer:
            self.frame.footer = self.footer
        else:
            self.frame.footer = None

        if loop:
            loop.set_alarm_in(2, self.update_torrents)

    def refresh_list(self):
        """Обновить список"""
        self.torrent_list.clear()

        # Получить ширину терминала
        term_width = self.loop.screen.get_cols_rows()[0]

        for i, torrent in enumerate(self.torrents):
            line = TorrentLine(
                i + 1,
                torrent,
                selected=(i == self.selected_index),
                term_width=term_width,
            )
            self.torrent_list.append(line)

        if self.torrents and self.selected_index >= len(self.torrents):
            self.selected_index = len(self.torrents) - 1

        if self.torrents and self.selected_index < len(self.torrents):
            try:
                self.listbox.set_focus(self.selected_index)
            except:
                pass

    def handle_input(self, key):
        """Обработка клавиш (vi keys)"""
        if key in ("q", "Q"):
            raise urwid.ExitMainLoop()

        # Vi-style навигация
        elif key in ("j", "down") and self.selected_index < len(self.torrents) - 1:
            self.selected_index += 1
            self.refresh_list()

        elif key in ("k", "up") and self.selected_index > 0:
            self.selected_index -= 1
            self.refresh_list()

        elif key == "g" and self.torrents:
            self.selected_index = 0
            self.refresh_list()

        elif key == "G" and self.torrents:
            self.selected_index = len(self.torrents) - 1
            self.refresh_list()

        # Управление
        elif key in ("s", "S") and self.torrents:
            torrent = self.torrents[self.selected_index]
            self.api.resume_torrent(torrent["hash"])
            self.update_torrents()

        elif key in ("p", "P") and self.torrents:
            torrent = self.torrents[self.selected_index]
            self.api.pause_torrent(torrent["hash"])
            self.update_torrents()

        elif key in ("r", "R") and self.torrents:
            self.show_remove_dialog()

        elif key in ("a", "A"):
            self.show_add_dialog()

        elif key in ("o", "O") and self.torrents:
            self.show_options_dialog()

        elif key in ("t", "T"):
            self.show_sort_dialog()

        elif key == " " and self.torrents:  # Пробел для toggle pause/resume
            torrent = self.torrents[self.selected_index]
            state = torrent.get("state", "")
            if state in ["pausedDL", "pausedUP"]:
                self.api.resume_torrent(torrent["hash"])
            else:
                self.api.pause_torrent(torrent["hash"])
            self.update_torrents()

        elif key == "?":
            self.show_footer = not self.show_footer
            if self.show_footer:
                self.frame.footer = self.footer
            else:
                self.frame.footer = None
            self.update_torrents()

    def show_remove_dialog(self):
        """Диалог удаления"""
        torrent = self.torrents[self.selected_index]
        name = (
            torrent["name"][:57] + "..."
            if len(torrent["name"]) > 60
            else torrent["name"]
        )

        question = urwid.Text(f"Remove '{name}'?", align="center")

        def on_yes_files(button):
            self.api.delete_torrent(torrent["hash"], True)
            self.loop.widget = self.frame
            self.update_torrents()

        def on_yes_torrent(button):
            self.api.delete_torrent(torrent["hash"], False)
            self.loop.widget = self.frame
            self.update_torrents()

        def on_no(button):
            self.loop.widget = self.frame

        pile = urwid.Pile(
            [
                urwid.Divider(),
                question,
                urwid.Divider(),
                urwid.AttrMap(
                    urwid.Button("Yes, with files", on_yes_files),
                    None,
                    focus_map="selected",
                ),
                urwid.AttrMap(
                    urwid.Button("Yes, torrent only", on_yes_torrent),
                    None,
                    focus_map="selected",
                ),
                urwid.AttrMap(urwid.Button("No", on_no), None, focus_map="selected"),
                urwid.Divider(),
            ]
        )

        overlay = urwid.Overlay(
            urwid.LineBox(urwid.Filler(pile, valign="top")),
            self.frame,
            "center",
            70,
            "middle",
            11,
        )
        self.loop.widget = overlay

    def show_add_dialog(self):
        """Диалог добавления с файловым менеджером"""
        path_edit = urwid.Edit("Path/URL/Magnet: ")
        file_list_walker = urwid.SimpleFocusListWalker([])
        file_listbox = urwid.BoxAdapter(urwid.ListBox(file_list_walker), height=5)

        def update_file_list(edit_widget, new_text):
            """Обновить список файлов при вводе пути"""
            file_list_walker.clear()
            path = os.path.expanduser(new_text.strip())

            if os.path.isdir(path):
                try:
                    files = [f for f in os.listdir(path) if f.endswith(".torrent")]
                    if files:
                        for f in sorted(files):
                            btn = urwid.Button(f)
                            urwid.connect_signal(
                                btn,
                                "click",
                                lambda b, fname=f: select_file(
                                    os.path.join(path, fname)
                                ),
                            )
                            file_list_walker.append(
                                urwid.AttrMap(btn, None, focus_map="selected")
                            )
                except:
                    pass

        def select_file(filepath):
            """Выбрать файл из списка"""
            path_edit.set_edit_text(filepath)

        urwid.connect_signal(path_edit, "change", update_file_list)

        def on_add(button):
            text = path_edit.get_edit_text().strip()
            if not text:
                self.loop.widget = self.frame
                return

            # Определить тип: URL, magnet или файл
            if (
                text.startswith("http://")
                or text.startswith("https://")
                or text.startswith("magnet:")
            ):
                self.api.add_torrent_url(text)
            else:
                filepath = os.path.expanduser(text)
                if os.path.isfile(filepath):
                    self.api.add_torrent_file(filepath)

            self.loop.widget = self.frame
            self.update_torrents()

        def on_cancel(button):
            self.loop.widget = self.frame

        pile = urwid.Pile(
            [
                urwid.Divider(),
                urwid.Text("Add torrent", align="center"),
                urwid.Divider(),
                path_edit,
                urwid.Divider(),
                file_listbox,
                urwid.Divider(),
                urwid.AttrMap(urwid.Button("Add", on_add), None, focus_map="selected"),
                urwid.AttrMap(
                    urwid.Button("Cancel", on_cancel), None, focus_map="selected"
                ),
                urwid.Divider(),
            ]
        )

        overlay = urwid.Overlay(
            urwid.LineBox(urwid.Filler(pile, valign="top")),
            self.frame,
            "center",
            70,
            "middle",
            20,
        )
        self.loop.widget = overlay

    def show_options_dialog(self):
        """Диалог опций"""
        torrent = self.torrents[self.selected_index]

        def on_recheck(button):
            self.api.recheck_torrent(torrent["hash"])
            self.loop.widget = self.frame
            self.update_torrents()

        def on_reannounce(button):
            self.api.reannounce_torrent(torrent["hash"])
            self.loop.widget = self.frame
            self.update_torrents()

        def on_magnet(button):
            magnet = self.api.get_magnet_link(torrent["hash"])
            if magnet:
                self.show_text_dialog("Magnet Link", magnet)
            else:
                self.show_text_dialog("Error", "Failed to get magnet link")

        def on_cancel(button):
            self.loop.widget = self.frame

        pile = urwid.Pile(
            [
                urwid.Divider(),
                urwid.Text("Options", align="center"),
                urwid.Divider(),
                urwid.AttrMap(
                    urwid.Button("Recheck", on_recheck), None, focus_map="selected"
                ),
                urwid.AttrMap(
                    urwid.Button("Reannounce", on_reannounce),
                    None,
                    focus_map="selected",
                ),
                urwid.AttrMap(
                    urwid.Button("Get Magnet Link", on_magnet),
                    None,
                    focus_map="selected",
                ),
                urwid.AttrMap(
                    urwid.Button("Cancel", on_cancel), None, focus_map="selected"
                ),
                urwid.Divider(),
            ]
        )

        overlay = urwid.Overlay(
            urwid.LineBox(urwid.Filler(pile, valign="top")),
            self.frame,
            "center",
            50,
            "middle",
            13,
        )
        self.loop.widget = overlay

    def show_text_dialog(self, title: str, text: str):
        """Показать текст в диалоге"""

        def on_close(button):
            self.loop.widget = self.frame

        text_widget = urwid.Edit(multiline=False)
        text_widget.set_edit_text(text)

        pile = urwid.Pile(
            [
                urwid.Divider(),
                urwid.Text(title, align="center"),
                urwid.Divider(),
                text_widget,
                urwid.Divider(),
                urwid.AttrMap(
                    urwid.Button("Close", on_close), None, focus_map="selected"
                ),
                urwid.Divider(),
            ]
        )

        overlay = urwid.Overlay(
            urwid.LineBox(urwid.Filler(pile, valign="top")),
            self.frame,
            "center",
            80,
            "middle",
            10,
        )
        self.loop.widget = overlay

    def run(self):
        """Запустить приложение"""
        self.update_torrents()
        self.loop.run()


def main():
    # Загрузка конфига
    config = Config()

    # Чтение настроек из файла или запрос
    host = config.get("host") or input("Host [localhost]: ").strip() or "localhost"
    port = config.get("port") or input("Port [8080]: ").strip() or "8080"
    username = config.get("username") or input("Username [admin]: ").strip() or "admin"
    password = config.get("password") or input("Password: ").strip()

    # Предложение сохранить настройки
    if not config.config:
        save = (
            input("Save settings to ~/.config/qbittorrent-tui/config.json? [y/N]: ")
            .strip()
            .lower()
        )
        if save == "y":
            save_password = (
                input("Save password too (NOT recommended)? [y/N]: ").strip().lower()
            )
            cfg = {"host": host, "port": port, "username": username}
            if save_password == "y":
                cfg["password"] = password
            config.save(cfg)
            print("✓ Settings saved")

    print("\nConnecting...")

    api = QBitAPI(host, int(port), username, password)

    if not api.login():
        print("Failed to connect!")
        sys.exit(1)

    print("✓ Connected!")
    time.sleep(0.5)

    app = QBitTUI(api)
    app.run()


if __name__ == "__main__":
    main()
