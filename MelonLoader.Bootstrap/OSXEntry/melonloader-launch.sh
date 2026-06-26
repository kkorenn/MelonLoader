#!/bin/bash
#
# MelonLoader launch wrapper for macOS Steam games.
#
# Why this exists:
#   When Steam on macOS launches a .app bundle, macOS LaunchServices creates
#   a fresh process that does not inherit the DYLD_INSERT_LIBRARIES env var
#   needed to inject MelonLoader. This wrapper sidesteps LaunchServices by
#   execing the inner binary directly with the env vars set, so the game
#   process inherits DYLD_INSERT_LIBRARIES the normal Unix way.
#
# Installation:
#   Install MelonLoader into the game folder (either via MelonLoader.Installer
#   or by extracting the macOS build zip). The resulting layout should be:
#
#     <steamapps>/common/<GameName>/
#     ├── <GameName>.app/
#     ├── MelonLoader.Bootstrap.dylib
#     ├── melonloader-launch.sh
#     └── MelonLoader/
#
#   Then set the game's Steam Launch Options to:
#     "/full/absolute/path/to/melonloader-launch.sh" %command%
#
#   Note: the path must be absolute. Steam on macOS does not resolve
#   relative paths in Launch Options relative to the game's common folder,
#   so "./melonloader-launch.sh" will fail with a generic launch error.
#
# The script auto-detects the .app bundle sitting next to it and resolves
# the game binary via Info.plist's CFBundleExecutable, so no per-game edits
# are required.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_PATH="$SCRIPT_DIR/MelonLoader.Bootstrap.dylib"

shell_quote() {
    printf "'%s'" "$(printf "%s" "$1" | sed "s/'/'\\\\''/g")"
}

# macOS 13+ on Apple Silicon (and increasingly strict in macOS 26/27 betas)
# enforces a bundle's code-signature seal at exec time. If the .app was modified
# after it was signed -- an installer replacing the inner binary, or dropping
# backup files like <Game>.real / *.bak / *.nativeumm_backup next to it -- the
# sealed-resources hash no longer matches and the kernel refuses to exec the
# binary. Steam surfaces this as a generic "OS Error 0" launch failure.
#
# Separately, even a perfectly valid hardened-runtime seal with Library
# Validation will reject our DYLD_INSERT_LIBRARIES injection of an unsigned
# bootstrap dylib.
#
# Ad-hoc re-signing the bundle solves both: it re-seals whatever is currently on
# disk (so `codesign --verify` passes again), and because we sign WITHOUT the
# runtime option it strips hardened runtime + Library Validation so the bootstrap
# can be inserted. This only runs when the seal is actually broken or a hardened
# runtime is present, so a clean, injectable bundle is left untouched.
ensure_bundle_signature() {
    command -v codesign >/dev/null 2>&1 || return 0

    local needs_resign=0
    if ! codesign --verify --strict "$APP" >/dev/null 2>&1; then
        needs_resign=1 # broken seal: kernel refuses exec on Apple Silicon
    elif codesign --display --verbose=2 "$BINARY" 2>&1 | grep -q "flags=.*runtime"; then
        needs_resign=1 # hardened runtime would block DYLD injection
    fi

    [ "$needs_resign" -eq 1 ] || return 0

    echo "melonloader-launch: ad-hoc re-signing $APP (broken seal or hardened runtime)" >&2
    codesign --force --deep --sign - "$APP" >/dev/null 2>&1 \
        || echo "melonloader-launch: ad-hoc re-sign failed; the game may fail to launch on Apple Silicon" >&2
}

open_melonloader_terminal() {
    if [ "${MELONLOADER_NO_TERMINAL:-0}" = "1" ]; then
        return
    fi

    if ! command -v open >/dev/null 2>&1; then
        return
    fi

    local log_path="$SCRIPT_DIR/MelonLoader/Latest.log"
    local title="MelonLoader - $(basename "$APP" .app)"
    local watcher_base watcher_script
    watcher_base="$(mktemp "${TMPDIR:-/tmp}/melonloader-log-tail.XXXXXX")" || return
    watcher_script="$watcher_base.command"
    mv "$watcher_base" "$watcher_script" || {
        rm -f "$watcher_base"
        return
    }

    local quoted_log_path quoted_title
    quoted_log_path="$(shell_quote "$log_path")"
    quoted_title="$(shell_quote "$title")"

    cat > "$watcher_script" <<EOF
#!/bin/bash
LOG_PATH=$quoted_log_path
TITLE=$quoted_title
GAME_PID=$$

printf '\\033]0;%s\\007' "\$TITLE"
clear
echo "\$TITLE"
echo "Waiting for MelonLoader log..."
echo

while [ ! -f "\$LOG_PATH" ] && kill -0 "\$GAME_PID" 2>/dev/null; do
    sleep 0.2
done

if [ -f "\$LOG_PATH" ]; then
    tail -n +1 -F "\$LOG_PATH" &
    TAIL_PID=\$!
    while kill -0 "\$GAME_PID" 2>/dev/null; do
        sleep 1
    done
    kill "\$TAIL_PID" 2>/dev/null || true
    wait "\$TAIL_PID" 2>/dev/null || true
else
    echo "MelonLoader log was not created."
fi

rm -f "\$0"
echo
echo "Game exited. You can close this window."
EOF

    chmod +x "$watcher_script"
    open -a Terminal "$watcher_script" >/dev/null 2>&1 || true
}

# Find the one .app bundle next to this script.
shopt -s nullglob
APPS=("$SCRIPT_DIR"/*.app)
shopt -u nullglob
if [ ${#APPS[@]} -ne 1 ]; then
    echo "melonloader-launch: expected exactly one .app bundle in $SCRIPT_DIR, found ${#APPS[@]}; launching without MelonLoader" >&2
    exec "$@"
fi
APP="${APPS[0]}"

# Resolve the game binary via CFBundleExecutable.
BINARY_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" "$APP/Contents/Info.plist" 2>/dev/null || true)
BINARY="$APP/Contents/MacOS/$BINARY_NAME"

if [ -z "$BINARY_NAME" ] || [ ! -x "$BINARY" ] || [ ! -f "$BOOTSTRAP_PATH" ]; then
    echo "melonloader-launch: missing binary ($BINARY) or bootstrap dylib ($BOOTSTRAP_PATH); launching without MelonLoader" >&2
    exec "$@"
fi

# If Steam handed us the .app bundle path (absolute or relative), redirect
# to the inner binary. Compare via realpath-style resolution so "./Foo.app"
# and "/abs/path/to/Foo.app" both match.
if [ -d "${1:-}" ] && [ "${1%.app}" != "$1" ]; then
    FIRST_ARG_ABS="$(cd "$1" && pwd)"
    if [ "$FIRST_ARG_ABS" = "$APP" ]; then
        shift
        set -- "$BINARY" "$@"
    fi
fi

# Repair a broken/hardened bundle seal before exec so macOS will launch it and
# allow injection. No-op when the bundle is already clean and injectable.
ensure_bundle_signature

# Both the dylib and the managed MelonLoader/ folder live in SCRIPT_DIR
# alongside the .app; point DYLD_LIBRARY_PATH there so the managed side's
# bare-filename NativeLibrary.Load("MelonLoader.Bootstrap.dylib") resolves.
export DYLD_LIBRARY_PATH="$SCRIPT_DIR"

# Prepend the bootstrap to Steam's own injected dylibs (overlay, steamloader)
# rather than replacing them, so the Steam overlay keeps working.
if [ -n "$STEAM_DYLD_INSERT_LIBRARIES" ]; then
    export DYLD_INSERT_LIBRARIES="$BOOTSTRAP_PATH:$STEAM_DYLD_INSERT_LIBRARIES"
else
    export DYLD_INSERT_LIBRARIES="$BOOTSTRAP_PATH"
fi

open_melonloader_terminal

exec "$@"
