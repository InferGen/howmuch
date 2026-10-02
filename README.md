# HowMuch

**Early access.**

HowMuch gives Claude Code users a local receipt for where their inference goes.

## Install

Requires macOS and Python 3.9 or newer.

```sh
curl -fsSL https://raw.githubusercontent.com/InferGen/howmuch/main/install.sh | sh
```

If the installer says `~/.local/bin` is not on your `PATH`, add:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Then try:

```sh
howmuch --version
howmuch today
howmuch week
```

## Privacy

HowMuch reads Claude Code session files locally from your Mac. It does not upload prompts, responses, or source code.

## Uninstall

```sh
rm ~/.local/bin/howmuch
rm -rf ~/.howmuch
```

HowMuch is early-access software. Output formats, quota estimates, and install behavior may change.
