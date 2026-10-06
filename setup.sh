#!/usr/bin/env bash
# Stage 0 of the first setup, for a Mac with nothing on it. This file is the
# source of the copy published outside the repo: the repo is private, so the
# first download cannot come from here. Keep it to what needs no repo access —
# git, gh, login, clone — and hand over to scripts/bootstrap.sh.
#
#   curl -fsSL <public-url>/setup.sh | bash
set -euo pipefail

# Piped through `curl | bash`, bash reads the script from stdin as it runs, and
# the `exec < /dev/tty` below would make it read the remaining lines from the
# keyboard — a silent hang. Inside a block, bash parses everything first.
{

REPO="DiscenTech/pelion"
DIR="${PELION_DIR:-$HOME/pelion}"

say() { printf '\n\033[1m▸ %s\033[0m\n' "$*"; }

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Questo script è per macOS. Su Linux: installa git, gh e Docker, poi" >&2
  echo "  gh repo clone $REPO && bash pelion/scripts/bootstrap.sh" >&2
  exit 1
fi

# Below Homebrew's Tier 1 there are no bottles: every formula builds from
# source, for hours, with no sign of progress. Tier 1 is Apple Silicon on the
# current macOS and the two before it — the same window Docker Desktop
# supports, so MIN_MACOS moves with each macOS release. scripts/setup.sh and
# scripts/bootstrap.sh carry the same check, called only before installing:
# a machine that already has everything passes on any Mac.
MIN_MACOS=15
require_supported_mac() {
  if [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" != "1" ]; then
    echo "Questo è un Mac con processore Intel: Homebrew non ha pacchetti pronti" >&2
    echo "per questi Mac e compilerebbe tutto da zero, per ore. Il setup automatico" >&2
    echo "si ferma qui: avvisa chi ti ha mandato queste istruzioni." >&2
    exit 1
  fi
  local macos major
  macos=$(sw_vers -productVersion 2>/dev/null || true)
  major=${macos%%.*}
  case "$major" in ''|*[!0-9]*) major=0 ;; esac
  if [ "$major" -lt "$MIN_MACOS" ]; then
    echo "Questo Mac ha macOS ${macos:-(versione non letta)}, e serve almeno macOS $MIN_MACOS: sulle" >&2
    echo "versioni più vecchie Homebrew compila tutto da zero (ore) e Docker Desktop non si installa." >&2
    echo "Aggiorna da Impostazioni di Sistema → Generali → Aggiornamento Software," >&2
    echo "poi rilancia lo stesso comando. Se l'aggiornamento non compare, il Mac è" >&2
    echo "troppo vecchio: avvisa chi ti ha mandato queste istruzioni." >&2
    exit 1
  fi
}

# Prompts (sudo, gh login) must read from the terminal, not from the pipe.
exec < /dev/tty

if ! xcode-select -p >/dev/null 2>&1; then
  require_supported_mac
  say "Installo gli strumenti da riga di comando di Apple (contengono git)"
  echo "Si apre una finestra: clicca «Installa» e aspetta che finisca."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

if ! command -v brew >/dev/null 2>&1; then
  require_supported_mac
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

command -v gh >/dev/null 2>&1 || { require_supported_mac; say "Installo GitHub CLI"; brew install gh; }

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

}
