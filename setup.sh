#!/usr/bin/env bash
# Stage 0 of the first setup, for a Mac with nothing on it. This file is the
# source of the copy published outside the repo: the repo is private, so the
# first download cannot come from here. Keep it to what needs no repo access —
# git, gh, login, clone — and hand over to scripts/bootstrap.sh.
#
#   curl -fsSL <public-url>/setup.sh | bash
set -euo pipefail

REPO="DiscenTech/pelion"
DIR="${PELION_DIR:-$HOME/pelion}"

say() { printf '\n\033[1m▸ %s\033[0m\n' "$*"; }

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Questo script è per macOS. Su Linux: installa git, gh e Docker, poi" >&2
  echo "  gh repo clone $REPO && bash pelion/scripts/bootstrap.sh" >&2
  exit 1
fi

# Piped through `curl | bash`, stdin is the script itself: prompts (sudo, gh
# login) must read from the terminal instead.
exec < /dev/tty

if ! xcode-select -p >/dev/null 2>&1; then
  say "Installo gli strumenti da riga di comando di Apple (contengono git)"
  echo "Si apre una finestra: clicca «Installa» e aspetta che finisca."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

if ! command -v brew >/dev/null 2>&1; then
  say "Installo Homebrew (ti chiederà la password del Mac)"
  # Pinned to a commit and checked against its hash before it runs: HEAD of
  # Homebrew/install is whatever that repo serves today. To bump, take a new
  # commit and `shasum -a 256` of its install.sh.
  brew_commit=f1f3f44a86c1cf81e45ec1caa43ab122a923c87a
  brew_sha256=5f333bbe53bc490e51e7ccb1df8779b3dd6ee73a1a7379efda216edb08ccb148
  installer=$(mktemp)
  curl -fsSL -o "$installer" "https://raw.githubusercontent.com/Homebrew/install/$brew_commit/install.sh"
  echo "$brew_sha256  $installer" | shasum -a 256 -c - >/dev/null \
    || { echo "L'installer di Homebrew non corrisponde all'hash atteso: mi fermo." >&2; exit 1; }
  /bin/bash "$installer"
  rm -f "$installer"
fi
for prefix in /opt/homebrew /usr/local; do
  [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)" && break
done

command -v gh >/dev/null 2>&1 || { say "Installo GitHub CLI"; brew install gh; }

if ! gh auth status >/dev/null 2>&1; then
  say "Accedi a GitHub: si apre il browser, conferma il codice che vedi qui"
  gh auth login --web --git-protocol https --hostname github.com
fi
gh auth setup-git

if [ ! -d "$DIR/.git" ]; then
  say "Scarico Pelion in $DIR"
  gh repo clone "$REPO" "$DIR"
fi

exec bash "$DIR/scripts/bootstrap.sh"
