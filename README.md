# macOS Workstation Setup

My opinionated macOS workstation setup managed by [chezmoi](https://www.chezmoi.io/) — dotfiles, Homebrew packages, browsers, developer tools, SSH keys, and system preferences in one bootstrap command.

## Quick Reference

### Initial Setup (on a new machine)

A single command bootstraps everything on a fresh Mac — chezmoi, Homebrew, and all packages:

**Step 1:** Install Xcode Command Line Tools (provides `git`, required by chezmoi):

```sh
xcode-select --install
```

A GUI dialog will appear — click **Install** and wait for it to complete.

**Step 2:** Bootstrap the workstation:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/ItsVRK/dotfiles.git
```

This works by:

1. Downloading chezmoi to `~/bin/chezmoi` (works on a bare Mac)
2. Cloning this repo and applying all dotfiles
3. Running `run_once_setup.sh.tmpl` which orchestrates the full setup:
   - **Homebrew** — installs Homebrew, the shared Nerd Font, and the `cask-upgrade` tap
   - **Cleanup** — replaces bootstrapped chezmoi with the Homebrew-managed version
   - **Mac App Store** — Mac App Store apps via mas (prompts to accept Xcode license if Xcode was installed)
   - **CLI Tools** — dev CLI tools and global packages (prompts for all/individual/skip)
   - **Browsers** — web browsers grouped by engine (prompts for all/individual/skip)
   - **Applications** — desktop apps by category (prompts for all/individual/skip)
   - **Making** — 3D printing, CAD, electronics tools (prompts for all/individual/skip)
   - **SSH Keys** — generates SSH keys via 1Password
   - **System Tweaks** — macOS defaults and preferences
   - **Documents** — creates subfolder structure in `~/Documents`

After setup completes, `chezmoi` lives at `/opt/homebrew/bin/chezmoi` managed by Homebrew.

### Everyday Commands

| Command | Description |
|---|---|
| `chezmoi add <file>` | Add a file to be managed by chezmoi |
| `chezmoi edit <file>` | Edit a managed file in your editor |
| `chezmoi diff` | Show pending changes (source vs target) |
| `chezmoi apply` | Apply all changes from source to target |
| `chezmoi merge` | Resolve conflicts between source and target |
| `chezmoi cd` | cd into the source directory (`~/.local/share/chezmoi`) |
| `chezmoi data` | View all template data (OS, hostname, etc.) |
| `chezmoi managed` | List all managed files |
| `chezmoi remove <file>` | Stop managing a file |
| `chezmoi forget <file>` | Stop managing a file (keeps target) |

### Adding a Dotfile

```sh
chezmoi add ~/.config/zsh/.zshrc     # add a file
chezmoi add --template ~/.gitconfig  # add as a template
```

### Editing Managed Files

```sh
chezmoi edit ~/.config/zsh/.zshrc    # opens in $EDITOR
# After saving, apply changes:
chezmoi apply
```

### Checking for Differences

```sh
chezmoi diff                         # preview what `apply` would change
chezmoi diff ~/.config/zsh/.zshrc    # check a specific file
```

### Committing & Pushing Changes

Use normal git commands to add, commit, and push changes to your remote repo.:

```sh
chezmoi cd                        # enter the source directory
git add -A
git commit -m "update dotfiles"
git push
```

### Templates

Templates use Go's `text/template` syntax with extra functions. Template variables are defined in `.chezmoi.yaml.tmpl`, which prompts on first run:

```yaml
# .chezmoi.yaml.tmpl
{{ $fullname := promptString "Git full name" -}}
{{ $email := promptString "Git email address" -}}

data:
    fullname: {{ $fullname | quote }}
    email: {{ $email | quote }}
```

These variables are then available in other templates:

```toml
# Example: dot_gitconfig.tmpl
[user]
    name = {{ .fullname }}
    email = {{ .email }}
```

Available template variables can be inspected with:

```sh
chezmoi data
```

Common variables include:

- `.chezmoi.os` — `linux`, `darwin`, `windows`, etc.
- `.chezmoi.hostname` — machine hostname
- `.chezmoi.username` — current user
- `.chezmoi.arch` — CPU architecture
- `.fullname`, `.email` — from `.chezmoi.yaml.tmpl` prompts

### Conditional Content in Templates

```gotemplate
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific settings
export PATH="/opt/homebrew/bin:$PATH"
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific settings
{{- end }}
```

### Syncing Across Machines

```sh
# Pull latest changes and apply
chezmoi update

# Or manually:
cd $(chezmoi source-path)
git pull
chezmoi apply
```

## Directory Structure

```
~/.local/share/chezmoi/                # source directory (this repo)
├── README.md
├── dot_zshenv                         # → ~/.zshenv (sets ZDOTDIR)
├── dot_config/
│   ├── ghostty/config                 # → ~/.config/ghostty/config
│   ├── private_karabiner/
│   │   └── private_karabiner.json     # → ~/.config/karabiner/karabiner.json
│   ├── starship.toml                  # → ~/.config/starship.toml
│   ├── wezterm/wezterm.lua            # → ~/.config/wezterm/wezterm.lua
│   └── zsh/
│       ├── dot_zprofile               # → ~/.config/zsh/.zprofile
│       └── dot_zshrc                  # → ~/.config/zsh/.zshrc
├── run_once_setup.sh.tmpl             # orchestrator (runs once on apply)
└── scripts/
    ├── cleanup-chezmoi.sh             # replaces bootstrapped chezmoi with Homebrew version
    ├── install-homebrew.sh            # installs Homebrew, font, cask-upgrade tap
    ├── install-cli-tools.sh              # dev CLI tools and global packages
    ├── install-browsers.sh              # web browsers (grouped by engine)
    ├── install-applications.sh          # desktop apps by category
    ├── install-making.sh                # 3D printing, CAD, electronics
    ├── setup-ssh-keys.sh               # generates SSH keys via 1Password
    ├── install-mas-apps.sh              # Mac App Store apps via mas
    ├── install-vscode-extensions.sh     # VS Code extensions
    └── system-tweaks.sh                 # macOS defaults and preferences
```

**Prefix/suffix conventions:**

- **`dot_` prefix** → maps to a `.` in the target (e.g. `dot_zshenv` → `~/.zshenv`)
- **`private_` prefix** → sets restrictive file permissions (e.g. `private_karabiner.json`)
- **`.tmpl` suffix** → file is processed as a Go template (supports prompts, conditionals, etc.)
- **`run_once_` prefix** → executed once on `chezmoi apply` (chezmoi tracks execution)
- **`exact_` prefix** → unmanaged files in that directory are removed on `apply`

## Configuration

Config template: `.chezmoi.yaml.tmpl` (in the source directory root)

On first `chezmoi init`, this template runs and prompts for values. The resulting config is written to `~/.config/chezmoi/chezmoi.yaml`.

See the [Templates](#templates) section above for the full `.chezmoi.yaml.tmpl` contents.

## Useful Links

- **Docs:** <https://www.chezmoi.io/>
- **User Guide:** <https://www.chezmoi.io/user-guide/command-overview/>
- **Templates:** <https://www.chezmoi.io/user-guide/templating/>
- **Full Command Reference:** <https://www.chezmoi.io/reference/commands/>
- **GitHub:** <https://github.com/twpayne/chezmoi>
