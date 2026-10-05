#!/bin/sh
# Install howmuch: one file, no admin rights, no account, no SnooZELab checkout.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/InferGen/howmuch/main/install.sh | sh
#   sh install.sh [--from PATH]
#
# It needs python3 3.9 or newer and installs a single file,
# $HOWMUCH_BIN_DIR/howmuch (default ~/.local/bin/howmuch), taken from:
#   --from PATH          a howmuch.pyz already on this machine, else
#   $HOWMUCH_PYZ_URL     a URL to download it from, else
#   DEFAULT_PYZ_URL      below.
# It writes nothing outside that folder and never edits your shell rc files.
# Running it again replaces the file with the new one.
# Uninstall: rm ~/.local/bin/howmuch (and ~/.howmuch, if you used `howmuch record`).

set -eu

DEFAULT_PYZ_URL="https://github.com/InferGen/howmuch/releases/latest/download/howmuch.pyz"

fail() {
    printf 'howmuch install: %s\n' "$*" >&2
    exit 1
}

usage() {
    printf '%s\n' \
        "Usage: sh install.sh [--from PATH]" \
        "Installs howmuch to \$HOWMUCH_BIN_DIR/howmuch (default ~/.local/bin/howmuch)." \
        "The file comes from --from PATH, else \$HOWMUCH_PYZ_URL, else $DEFAULT_PYZ_URL."
}

from=""
while [ $# -gt 0 ]; do
    case "$1" in
        --from)
            [ $# -ge 2 ] || fail "--from needs a path to howmuch.pyz"
            from=$2
            shift 2
            ;;
        --from=*)
            from=${1#--from=}
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            fail "unknown option: $1 (see sh install.sh --help)"
            ;;
    esac
done

# Python 3.9 or newer, checked before anything is written.
command -v python3 >/dev/null 2>&1 ||
    fail "python3 not found. howmuch needs Python 3.9 or newer (https://www.python.org/downloads/). Nothing was installed."
version=$(python3 --version 2>&1 | sed -n 's/^Python \([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')
major=${version% *}
minor=${version#* }
if [ -z "$version" ] || [ "$major" -lt 3 ] || { [ "$major" -eq 3 ] && [ "$minor" -lt 9 ]; }; then
    found=$(python3 --version 2>&1 | head -n 1)
    fail "howmuch needs Python 3.9 or newer, but python3 is: ${found:-unknown}. Nothing was installed."
fi

bin_dir=${HOWMUCH_BIN_DIR:-$HOME/.local/bin}
target="$bin_dir/howmuch"
case "$bin_dir" in
    "$HOME"/*) shown_dir="~${bin_dir#"$HOME"}" rc_dir="\$HOME${bin_dir#"$HOME"}" ;;
    *) shown_dir=$bin_dir rc_dir=$bin_dir ;;
esac

mkdir -p "$bin_dir" || fail "could not create $shown_dir. Nothing was installed."
# The new file is written next to the old one and moved into place, so a
# failed download never leaves a broken howmuch behind.
tmp="$bin_dir/.howmuch.install.$$"
trap 'rm -f "$tmp"' EXIT
trap 'exit 1' HUP INT TERM

if [ -n "$from" ]; then
    [ -f "$from" ] || fail "no file at $from. Nothing was installed."
    cp "$from" "$tmp" || fail "could not copy $from into $shown_dir. Nothing was installed."
else
    url=${HOWMUCH_PYZ_URL:-$DEFAULT_PYZ_URL}
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$tmp" || fail "could not download $url. Nothing was installed."
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$tmp" "$url" || fail "could not download $url. Nothing was installed."
    else
        fail "need curl or wget to download $url (or use --from PATH). Nothing was installed."
    fi
fi

python3 "$tmp" --version >/dev/null 2>&1 || fail "the downloaded file is not a working howmuch. Nothing was installed."
chmod 755 "$tmp"
mv -f "$tmp" "$target"

installed=$("$target" --version) || fail "installed $shown_dir/howmuch, but it did not run."
printf 'Installed %s to %s/howmuch\n' "$installed" "$shown_dir"
case ":${PATH:-}:" in
    *":$bin_dir:"*)
        printf '%s\n' "Try it: howmuch today"
        ;;
    *)
        printf '%s\n' "$shown_dir is not on your PATH. Add this line to ~/.zshrc, then open a new terminal:"
        printf '  export PATH="%s:$PATH"\n' "$rc_dir"
        printf '%s\n' "Then try it: howmuch today"
        ;;
esac
