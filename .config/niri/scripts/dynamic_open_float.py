#!/usr/bin/python3
"""
Niri Auto-Float Daemon
Fixes Bitwarden/Zen/Firefox extensions and Steam windows not floating/sizing correctly.
"""

from dataclasses import dataclass, field
import json
import os
import re
from socket import AF_UNIX, SHUT_WR, socket
import sys

# --- CONFIGURATION ---


@dataclass(kw_only=True)
class Match:
    title: str | None = None
    app_id: str | None = None

    def matches(self, window):
        if self.title is None and self.app_id is None:
            return False
        matched = True
        if self.title is not None:
            matched &= re.search(self.title, window.get("title", "")) is not None
        if self.app_id is not None:
            matched &= re.search(self.app_id, window.get("app_id", "")) is not None
        return matched


@dataclass
class Rule:
    match: list[Match] = field(default_factory=list)
    exclude: list[Match] = field(default_factory=list)
    # If 0, keeps current size
    width: int = 0
    height: int = 0
    centered: bool = False

    def matches(self, window):
        if len(self.match) > 0 and not any(m.matches(window) for m in self.match):
            return False
        if any(m.matches(window) for m in self.exclude):
            return False
        return True


# --- YOUR RULES ---
RULES = [
    # 1. Browser Extensions (Bitwarden, etc)
    #    Fixed size: 450x650 (Good for standard extension popups)
    Rule([Match(title=r"^Extension: \(.*\)")], width=450, height=650, centered=True),
    # 2. Picture-in-Picture (Small, bottom right usually, but let's float it)
    Rule([Match(title=r"^Picture-in-Picture$")]),
    # 3. Browser Library/Downloads
    Rule(
        [Match(title=r"^Library$", app_id=r"(firefox|zen)")],
        width=900,
        height=600,
        centered=True,
    ),
    # 4. Save/Open Dialogs
    Rule(
        [
            Match(
                title=r"^(Open File|Save As|Enter name of file to save to|File Upload)$"
            )
        ],
        width=1000,
        height=700,
        centered=True,
    ),
    # 5. Steam Friends List
    Rule(
        [Match(app_id=r"^steam$", title=r"^Friends List$")],
        width=350,
        height=700,
        centered=False,
    ),
    # 6. Generic Steam Dialogs
    Rule(
        [Match(app_id=r"^steam$", title=r"^(Steam - News|Settings|.* - Properties)$")],
        centered=True,
    ),
    # 7. Calculator
    Rule([Match(app_id=r".*calculator.*")], width=400, height=500, centered=True),
]

# --- NIRI IPC LOGIC ---

if len(RULES) == 0:
    print("No rules defined.")
    sys.exit()

try:
    NIRI_SOCKET = os.environ["NIRI_SOCKET"]
except KeyError:
    print("NIRI_SOCKET not found. Is niri running?")
    sys.exit(1)


def send(request):
    """Helper to send JSON to Niri socket"""
    with socket(AF_UNIX) as s:
        s.connect(NIRI_SOCKET)
        f = s.makefile("rw")
        f.write(json.dumps(request))
        f.flush()


def do_float(id: int):
    send({"Action": {"MoveWindowToFloating": {"id": id}}})


def do_focus(id: int):
    send({"Action": {"FocusWindow": {"id": id}}})


def do_resize(id: int, width: int, height: int):
    # We send both at once if possible, but separate actions are safer in loops
    if width > 0:
        send({"Action": {"SetWindowWidth": {"id": id, "change": {"SetFixed": width}}}})
    if height > 0:
        send(
            {"Action": {"SetWindowHeight": {"id": id, "change": {"SetFixed": height}}}}
        )


def do_center(id: int, width: int, height: int):
    # To center, we move top-left to 50%, then offset by negative half-size
    if width == 0 or height == 0:
        # Cannot strictly center without knowing size, fallback to simple 50%
        # This will put top-left at center of screen (imperfect)
        send(
            {
                "Action": {
                    "MoveFloatingWindow": {
                        "id": id,
                        "x": {"SetProportion": 0.5},
                        "y": {"SetProportion": 0.5},
                    }
                }
            }
        )
        return

    # 1. Place at 50% 50%
    send(
        {
            "Action": {
                "MoveFloatingWindow": {
                    "id": id,
                    "x": {"SetProportion": 0.5},
                    "y": {"SetProportion": 0.5},
                }
            }
        }
    )
    # 2. Offset back by half size
    send(
        {
            "Action": {
                "MoveFloatingWindow": {
                    "id": id,
                    "x": {"AdjustFixed": -(width / 2)},
                    "y": {"AdjustFixed": -(height / 2)},
                }
            }
        }
    )


# --- EVENT LOOP ---

windows = {}


def update_matched(win):
    win_id = win["id"]
    # Initialize state
    if "matched" not in win:
        win["matched"] = False

    # Check if we already processed this window ID to avoid loops
    # (Though we re-check in case title changed)
    previous_match = win["matched"]

    # Check rules
    active_rule = None
    for r in RULES:
        if r.matches(win):
            active_rule = r
            break

    if active_rule:
        win["matched"] = True

        # Only act if it wasn't matched before (Trigger ONCE)
        if not previous_match:
            print(f"Matched: {win.get('title')} -> Floating")

            # 1. Float it
            do_float(win_id)

            # 2. Resize it (Important to do this before centering)
            if active_rule.width > 0 or active_rule.height > 0:
                do_resize(win_id, active_rule.width, active_rule.height)

            # 3. Center it
            if active_rule.centered:
                do_center(win_id, active_rule.width, active_rule.height)

            # 4. Focus it (Crucial for popups)
            do_focus(win_id)

    else:
        win["matched"] = False


def main():
    # Connect to event stream
    s = socket(AF_UNIX)
    s.connect(NIRI_SOCKET)
    f = s.makefile("rw")
    f.write('"EventStream"')
    f.flush()
    s.shutdown(SHUT_WR)

    for line in f:
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        if "WindowsChanged" in event:
            changed_windows = event["WindowsChanged"]["windows"]
            for w in changed_windows:
                # Merge with existing known state if needed, or update
                windows[w["id"]] = w
                update_matched(w)

        elif "WindowOpenedOrChanged" in event:
            w = event["WindowOpenedOrChanged"]["window"]
            windows[w["id"]] = w
            update_matched(w)

        elif "WindowClosed" in event:
            wid = event["WindowClosed"]["id"]
            if wid in windows:
                del windows[wid]


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print(f"Error: {e}")
