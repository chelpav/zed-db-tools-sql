#!/usr/bin/env bash
# Installs the "SQL (db-tools tmpl)" Zed extension.
# Places a COPY of this folder into Zed's extensions directory (same layout
# as a marketplace install). The grammar ships prebuilt (grammars/jinja2.wasm)
# so no compilation and no network access are needed.
# Update: unpack a new version over this folder and run the script again.
set -e

EXT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$(uname)" == "Darwin" ]]; then
    DEST="$HOME/Library/Application Support/Zed/extensions/installed"
else
    DEST="${XDG_DATA_HOME:-$HOME/.local/share}/zed/extensions/installed"
fi

mkdir -p "$DEST"
# Remove previous installs: an old copy/symlink and any leftover
# from the Install Dev Extension button
rm -rf "$DEST/db-tools-sql" "$(dirname "$DEST")/dev/db-tools-sql"
# Copy (symlinks on Windows require Developer Mode; a copy is universal)
cp -R "$EXT_DIR" "$DEST/db-tools-sql"
rm -rf "$DEST/db-tools-sql/grammars/jinja2" 2>/dev/null || true

echo "Installed (copy): $DEST/db-tools-sql"
echo "Now fully restart Zed."
echo "Check: open any *.sql.tmpl file — the language in the bottom right"
echo "corner should be 'SQL (db-tools tmpl)'."
