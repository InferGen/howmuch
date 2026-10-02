#!/bin/sh
# Install HowMuch: one file, no admin rights, no SnooZELab checkout.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/InferGen/howmuch/main/install.sh | sh

set -eu

DEFAULT_PYZ_B64_URL="https://raw.githubusercontent.com/InferGen/howmuch/main/howmuch.pyz.b64"

fail() {
    printf 'howmuch install: %s\n' "$*" >&2
    exit 1
}

command -v python3 >/dev/null 2>&1 ||
    fail "python3 not found. HowMuch needs Python 3.9 or newer. Nothing was installed."

version=$(python3 --version 2>&1 | sed -n 's/^Python \([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')
major=${version% *}
minor=${version#* }
if [ -z "$version" ] || [ "$major" -lt 3 ] || { [ "$major" -eq 3 ] && [ "$minor" -lt 9 ]; }; then
    found=$(python3 --version 2>&1 | head -n 1)
    fail "HowMuch needs Python 3.9 or newer, but python3 is: ${found:-unknown}. Nothing was installed."
fi

bin_dir=${HOWMUCH_BIN_DIR:-$HOME/.local/bin}
target="$bin_dir/howmuch"
mkdir -p "$bin_dir" || fail "could not create $bin_dir. Nothing was installed."

tmp_b64="$bin_dir/.howmuch.install.$$.b64"
tmp="$bin_dir/.howmuch.install.$$"
trap 'rm -f "$tmp_b64" "$tmp"' EXIT
trap 'exit 1' HUP INT TERM

url=${HOWMUCH_PYZ_B64_URL:-$DEFAULT_PYZ_B64_URL}
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$tmp_b64" || fail "could not download $url. Nothing was installed."
elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$tmp_b64" "$url" || fail "could not download $url. Nothing was installed."
else
    fail "need curl or wget to download HowMuch. Nothing was installed."
fi

if base64 --help 2>&1 | grep -q -- '--decode'; then
    base64 --decode "$tmp_b64" > "$tmp"
else
    base64 -D "$tmp_b64" > "$tmp"
fi

python3 "$tmp" --version >/dev/null 2>&1 ||
    fail "the downloaded file is not a working HowMuch build. Nothing was installed."

chmod 755 "$tmp"
mv -f "$tmp" "$target"

installed=$("$target" --version) || fail "installed $target, but it did not run."
printf 'Installed %s to %s\n' "$installed" "$target"

case ":${PATH:-}:" in
    *":$bin_dir:"*)
        printf '%s\n' "Try it: howmuch today"
        ;;
    *)
        printf '%s\n' "$bin_dir is not on your PATH. Add this line to ~/.zshrc, then open a new terminal:"
        printf '  export PATH="%s:$PATH"\n' "$bin_dir"
        printf '%s\n' "Then try it: howmuch today"
        ;;
esac
