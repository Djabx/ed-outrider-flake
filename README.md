# ED-Outrider Nix Flake

Nix flake packaging for [ED-Outrider](https://github.com/weslocke/ED-Outrider), an exploration companion and cockpit assistant for Elite Dangerous.

## Features

- **XDG Compliance**: Patched to store database, logs and settings in `$XDG_DATA_HOME` (`~/.local/share/ed-outrider`) and `$XDG_CONFIG_HOME` (`~/.config/ed-outrider`) instead of the read-only Nix store.
- **Wayland & X11 Clipboard**: Bundles `wl-clipboard` and `xclip` in PATH for automatic route plotting clipboard integration.
- **In-Game Overlay**: Includes `ed-outrider-overlay` wrapper with PyQt6 support.

## Usage

### Run directly with `nix run`

Run the local web server:
```bash
nix run
# Or explicitly:
nnix run .#default
```

Run the in-game overlay:
```bash
nnix run .#overlay
```
