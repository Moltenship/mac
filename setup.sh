#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dry_run=false
settings_only=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --settings-only) settings_only=true ;;
    -h|--help)
      echo 'Usage: ./setup.sh [--dry-run] [--settings-only]'
      echo 'Install/update apps and tools, then copy settings with backups.'
      exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != Darwin ]]; then
  echo 'This setup supports macOS only.' >&2
  exit 1
fi

run() {
  if "$dry_run"; then
    printf 'Would run:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

# Work even before Homebrew has been added to the shell startup files.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! "$settings_only"; then
  if ! command -v brew >/dev/null; then
    echo 'Install Homebrew from https://brew.sh, then rerun this script.' >&2
    exit 1
  fi
  run brew update
  run brew bundle install --file="$repo_dir/Brewfile"
  # Target personal defaults, independent of the directory you launch from.
  # Resolve latest again on every run, including across Node major releases.
  (
    cd "$HOME"
    run mise use --global node@latest
    run mise exec node@latest -- npm install --global @openai/codex@latest
  )
  code_bin='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
  while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -n "$extension" && "$extension" != \#* ]] || continue
    run "$code_bin" --install-extension "$extension" --force
  done < "$repo_dir/vscode/extensions.txt"
fi

backup_dir=''
install_setting() {
  local source="$1" destination="$2" relative="$3"
  if [[ -f "$destination" ]] && cmp -s "$source" "$destination"; then
    echo "Already matches: $destination"
    return
  fi
  if "$dry_run"; then
    echo "Would back up existing file and copy: $source -> $destination"
    return
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    if [[ -z "$backup_dir" ]]; then
      mkdir -p "$HOME/.local/state/mac-setup"
      backup_dir="$(mktemp -d "$HOME/.local/state/mac-setup/backup.XXXXXXXX")"
    fi
    mkdir -p "$backup_dir/$(dirname "$relative")"
    mv "$destination" "$backup_dir/$relative"
  fi
  mkdir -p "$(dirname "$destination")"
  cp "$source" "$destination"
  echo "Copied: $destination"
}

install_setting "$repo_dir/dotfiles/zshrc" "$HOME/.zshrc" '.zshrc'
install_setting "$repo_dir/dotfiles/cmux.json" "$HOME/.config/cmux/cmux.json" '.config/cmux/cmux.json'
install_setting "$repo_dir/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json" 'Code/settings.json'
install_setting "$repo_dir/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json" 'Code/keybindings.json'

# Disable the accent popup when holding a key.
run defaults write -g ApplePressAndHoldEnabled -bool false

[[ -z "$backup_dir" ]] || echo "Previous settings saved in: $backup_dir"
if "$dry_run"; then
  echo 'Preview complete. No apps, tools, or settings were changed.'
else
  echo 'Setup complete. Open a new terminal and restart VS Code and cmux.'
  echo 'See README.md for sign-ins and Git identity setup.'
fi
