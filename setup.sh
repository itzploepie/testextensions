#!/usr/bin/env bash
# setup.sh
#
#   ./setup.sh          remove apps, then restore extensions and settings from ./gnome
#   ./setup.sh export   save this machine's extensions and settings into ./gnome
#
# Run it as your normal user inside a logged-in GNOME session. It calls
# sudo itself for the dnf step.

set -euo pipefail

if [ "$EUID" -eq 0 ]; then
    echo "Run this as your normal user, not with sudo." >&2
    exit 1
fi

REPO_DIR="$(dirname "$(readlink -f "$0")")"
BUNDLE="$REPO_DIR/gnome"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
DCONF_PATH="/org/gnome/shell/extensions/"

debloat() {
    sudo dnf remove gnome-weather gnome-tour gnome-font-viewer gnome-contacts gnome-connections gnome-clocks gnome-characters gnome-calendar gnome-calculator gnome-boxes libreoffice-core \
        || echo "dnf remove failed or was cancelled, continuing" >&2
}

# Warn about extensions whose metadata.json does not list the running
# GNOME Shell major version. Only warns, never edits anything.
check_versions() {
    local shell_ver
    shell_ver="$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -n1 || true)"
    [ -n "$shell_ver" ] || return 0

    local meta
    for meta in "$EXT_DIR"/*/metadata.json; do
        [ -f "$meta" ] || continue
        python3 - "$meta" "$shell_ver" <<'PY' || true
import json, sys
path, ver = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
versions = [str(v).split(".")[0] for v in data.get("shell-version", [])]
if ver not in versions:
    print(f"warning: {data.get('uuid', path)} does not list GNOME Shell {ver}")
PY
    done
}

export_settings() {
    mkdir -p "$BUNDLE"
    rm -rf "$BUNDLE/extensions"
    cp -a "$EXT_DIR" "$BUNDLE/extensions"
    dconf dump "$DCONF_PATH" > "$BUNDLE/extensions.dconf"
    gsettings get org.gnome.shell enabled-extensions > "$BUNDLE/enabled-extensions.txt"
    echo "Saved to $BUNDLE"
}

import_settings() {
    [ -d "$BUNDLE/extensions" ] || { echo "No bundle found at $BUNDLE" >&2; exit 1; }
    mkdir -p "$EXT_DIR"
    cp -a "$BUNDLE/extensions/." "$EXT_DIR/"
    dconf load "$DCONF_PATH" < "$BUNDLE/extensions.dconf"
    gsettings set org.gnome.shell enabled-extensions "$(cat "$BUNDLE/enabled-extensions.txt")"
    gsettings set org.gnome.shell disable-user-extensions false
    check_versions
    echo "Done. Log out and back in to load the extensions."
}

case "${1:-}" in
    export)
        export_settings
        ;;
    "")
        debloat
        import_settings
        ;;
    *)
        echo "Usage: $0 [export]" >&2
        exit 1
        ;;
esac
