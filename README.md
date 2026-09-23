# My Mac setup

Apps, development tools, and settings for my Macs. Packages follow current releases;
Node, pnpm, and Bun follow `latest` (including new major versions), and T3 Code follows Nightly.

## New Mac

1. Install [Homebrew](https://brew.sh), following its instructions for Command Line
   Tools and adding Homebrew to your shell. Full Xcode is not required for this setup.
2. Clone this repository, or download and extract its ZIP from GitHub:

   ```sh
   git clone https://github.com/Moltenship/mac.git
   cd mac
   ```

3. In its directory, preview and run:

   ```sh
   ./setup.sh --dry-run
   ./setup.sh
   ```

4. Open a new terminal and restart VS Code and cmux.
5. Sign in to VS Code Settings Sync to restore your Default profile, then complete
   the other sign-ins below.

The script installs/updates Homebrew packages, selects the latest Node, pnpm, and Bun with mise,
installs the latest Codex CLI into that Node installation, and copies shell, Atuin,
and cmux settings. VS Code settings and extensions are managed by Settings Sync unless
you explicitly request the saved snapshot below. Run the script from any directory
using its full path.
It supports the standard Homebrew locations on Apple Silicon and Intel Macs;
individual apps may have their own OS or architecture requirements.

## Included

| Category | Contents |
| --- | --- |
| Apps | 1Password, Chrome, Raycast, Shottr, Spotify, Telegram, VS Code, Vorssaint, cmux, T3 Code Nightly |
| CLI | Git, GitHub CLI, mise, Starship, Codex CLI, fzf, fzf-tab, Atuin, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions |
| Runtime | Node `latest`, managed by mise |
| Package managers | pnpm `latest` and Bun `latest`, managed by mise; Bun also provides a runtime |
| Settings | zsh, Atuin, selected cmux preferences, VS Code settings and keybindings, press-and-hold disabled |
| Editor snapshot (opt-in) | Default profile settings, keybindings, and extension IDs in `vscode/` |

**Telegram, T3 Code Nightly, Spotify, and Chrome are essential:** all four are
installed automatically by `./setup.sh` through Homebrew, with no manual downloads.
You still sign in on each new Mac; account sessions are not stored in this repo.

Vorssaint requires Apple Silicon and macOS 14 or later. Remove its Brewfile entry
before running setup on an Intel Mac.

Helium is optional: uncomment its line in `Brewfile` to include it. Apple-bundled
apps are omitted. No additional languages or container tools have been added.

## Update

Pull your repo changes, then rerun:

```sh
./setup.sh
```

This updates packages listed in the Brewfile, selects Node, pnpm, and Bun `latest` again, and
reinstalls Codex for the selected Node version. Self-updating desktop apps also
use their built-in updaters. Homebrew's package catalog can lag upstream releases;
this is not a background update service. The script does not remove unlisted apps
or old Node versions.

To install/update only Homebrew packages:

```sh
brew update
brew bundle install --file=Brewfile
```

On an existing Mac, Homebrew Bundle attempts to adopt manually installed app
bundles. If an existing app differs from the downloaded copy, it can report a
conflict. Resolve that particular app before rerunning; this script does not
force replacement of application bundles.

## Settings and backups

```sh
./setup.sh --settings-only --dry-run
./setup.sh --settings-only
```

Both full setup and settings-only mode also apply:

```sh
defaults write -g ApplePressAndHoldEnabled -bool false
```

This disables the press-and-hold accent popup. Restart affected apps after applying
it. This macOS preference is not included in the file backups below; to re-enable
it, run the same command with `true`. Dry-run mode only prints the command.

Existing differing settings are moved to a unique directory under
`~/.local/state/mac-setup/backup.*` before copies are installed. The script prints
the backup directory. Matching files are left alone. Copies are used, so the repo
does not have to stay at the same path. To undo a settings change, copy the old file
from that backup to its original location; VS Code backups are under `Code/`.

Edit the repo copies to maintain your preferred settings. Changes made inside
apps do not automatically update this repo, and running setup reapplies the repo
versions for shell, Atuin, and cmux. Close cmux before applying its settings.

### Zsh with Starship

The shell adds searchable completions, history suggestions, syntax highlighting,
and Atuin history search. Starship keeps its existing appearance. No shell plugin
framework or persistent background service is required.

| Shortcut | Action |
| --- | --- |
| Tab | Search Zsh completion candidates with fzf-tab |
| Right Arrow at the end of a line | Accept the gray history suggestion |
| Ctrl-R | Search Atuin history; Enter inserts the selection for editing |
| Ctrl-T | Pick files with fzf and insert their paths |
| Option-C, with Option configured as Alt | Pick a directory with fzf |
| Ctrl-X then Ctrl-E | Edit the command using `$VISUAL` or `$EDITOR` |
| Up Arrow | Keep normal Zsh history navigation |

Atuin records new commands locally. To bring existing Zsh history into its local
database once, run `atuin import zsh`. Sync and automatic update checks are
disabled in `dotfiles/atuin.toml`; Homebrew handles package updates. Atuin's AI
keybinding is disabled. Its database and account files are never copied to this
repository.

Performance choices in `dotfiles/zshrc`:

- Reuse Homebrew's environment when `.zprofile` already initialized it.
- Load plugin scripts directly, including fzf's keybindings, without a plugin manager.
- Let `compinit` cache completion definitions while retaining permission checks.
- Generate suggestions asynchronously from Zsh's in-memory history. Override
  Atuin's default suggestion integration to avoid a database process per keystroke.
- Open completion and file searches only when requested, with no preview commands.
- Bind autosuggestion widgets once at the first prompt. If a local customization
  replaces widgets later, call `_zsh_autosuggest_bind_widgets` after changing them.
- Stop suggesting past 200 characters and highlighting past 1,000 characters so
  long pasted commands do less work.
- Keep 20,000 entries in native Zsh history; Atuin retains the richer history.

If `compinit` reports insecure directories, run `autoload -Uz compaudit; compaudit`
in Zsh and inspect the listed paths. On this Mac, `/opt/homebrew/share` needed
`chmod g-w /opt/homebrew/share`. Fix the reported permissions rather than disabling
the check or recursively changing the whole Homebrew installation.

Shell customizations belong in `~/.zshrc.local`, loaded before autosuggestions and
syntax highlighting. These two plugins must follow widget definitions.

### VS Code: one Default profile

Main's configuration has been moved into Default, and Main has been deleted.
Use Settings Sync for ongoing editor configuration, snippets, tasks, UI state, and
extensions. The repo does not create Main or copy profile IDs or Sync databases.

Normal setup (including `--settings-only`) leaves VS Code settings and extensions
alone. If you need the reviewed public snapshot instead of Sync, close VS Code,
pause Sync, and explicitly restore it:

```sh
./setup.sh --settings-only --restore-vscode --dry-run
./setup.sh --settings-only --restore-vscode
```

VS Code must already be installed for this settings-only restore. Omit
`--settings-only` to install apps and tools too. Restoration backs up settings and
keybindings, replaces them with the sanitized snapshot, and installs the listed
extensions explicitly into Default. Extra installed extensions are not removed.
Snippets, tasks, MCP configuration, extension enablement, and UI state are not in
this snapshot; restore those through Sync or a private profile backup.

Machine-specific shell additions belong in `~/.zshrc.local`. The shell config
initializes Homebrew, mise, and Starship without hardcoded usernames. On this Mac,
mise was originally installed in `~/.local/bin`; new installs use Homebrew's mise.

The editor configuration was sanitized: credentials, old user-specific Node
and Python paths, Windows/Linux terminal profiles, work-service URLs, and the
personal spelling dictionary were excluded. No credentials, app sessions, or
browser profiles are captured. Git currently has only name/email settings, which
are configured per machine below instead of being copied into this repo.

The cmux file captures appearance, sidebar tint, and external-browser link
preferences. Session state, browser profiles, window geometry, and device IDs are
not transferred. Its Ghostty config was empty; Starship uses its default config.

## Finish manually

- Sign in to 1Password, Chrome, Raycast, Spotify, Telegram, T3 Code, and your coding services.
- Run `gh auth login` and `codex login` for CLI authentication.
- Set your Git identity:

  ```sh
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
  ```

- Configure SSH/signing keys through your existing key-management workflow.
- Restore Raycast settings using its export/import or sync feature, and grant
  requested accessibility/other permissions. Raycast's private state is not in Git.
- Set default browser, login items, and any other macOS preferences you want.
- The VS Code font stack requests Iosevka and other fonts, but none were installed
  in the inspected user font directory. It falls back to system fonts. Add a font
  cask to the Brewfile if you want one installed explicitly.
- Review `vscode/extensions.txt` if you want a smaller extension snapshot; it
  captures the installed Default profile extensions after the Sync migration.

## Maintain and share

Edit `Brewfile` when adding/removing apps or CLI tools. Edit
`vscode/extensions.txt` for extensions. Keep credentials outside the repository,
even if it is private. Commit and push reviewed changes to your own GitHub repo.

The first implementation has been checked locally with shell syntax validation,
Brewfile parsing, dry-run output, and isolated settings backup/reapply checks.
A complete installation on a fresh Mac has not yet been tested.
