#!/usr/bin/env python3
"""Write Dash to Panel per-monitor settings using this machine's monitor IDs.

Run it inside the graphical session (it asks Mutter which monitors exist).
"""
import json
import subprocess

from gi.repository import Gio, GLib

DCONF_PATH = "/org/gnome/shell/extensions/dash-to-panel/"
PANEL_SIZE = 40

# (element, visible, position), copied from your dump
ELEMENTS = [
    ("showAppsButton", False, "stackedTL"),
    ("activitiesButton", False, "stackedTL"),
    ("rightBox", True, "stackedTL"),
    ("leftBox", True, "centerMonitor"),
    ("taskbar", True, "centerMonitor"),
    ("centerBox", False, "stackedBR"),
    ("dateMenu", True, "stackedBR"),
    ("systemMenu", True, "stackedBR"),
    ("desktopButton", True, "stackedBR"),
]


def monitor_ids():
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    state = bus.call_sync(
        "org.gnome.Mutter.DisplayConfig",
        "/org/gnome/Mutter/DisplayConfig",
        "org.gnome.Mutter.DisplayConfig",
        "GetCurrentState",
        None, None, Gio.DBusCallFlags.NONE, -1, None,
    ).unpack()
    # state[1] is the monitor list, each entry starts with
    # (connector, vendor, product, serial)
    specs = [m[0] for m in state[1]]
    ids = [f"{s[1]}-{s[3]}" for s in specs]
    if len(set(ids)) != len(ids):
        # two identical monitors: fall back to the connector name
        ids = [s[0] for s in specs]
    return ids


def write(key, value):
    compact = json.dumps(value, separators=(",", ":"))
    gvariant_text = GLib.Variant("s", compact).print_(False)
    subprocess.run(["dconf", "write", DCONF_PATH + key, gvariant_text], check=True)


def main():
    ids = monitor_ids()
    print("monitor ids:", ids)
    layout = [
        {"element": e, "visible": v, "position": p} for e, v, p in ELEMENTS
    ]
    write("panel-anchors", {i: "MIDDLE" for i in ids})
    write("panel-element-positions", {i: layout for i in ids})
    write("panel-sizes", {i: PANEL_SIZE for i in ids})


if __name__ == "__main__":
    main()
