# ED-Outrider Nix Flake

Nix flake packaging for [ED-Outrider](https://github.com/weslocke/ED-Outrider), an exploration companion and cockpit assistant for Elite Dangerous.

## Features

- **XDG Compliance**: Patched to store database, logs and settings in `$XDG_DATA_HOME` (`~/.local/share/ed-outrider`) and `$XDG_CONFIG_HOME` (`~/.config/ed-outrider`) instead of the read-only Nix store.
- **Wayland & X11 Clipboard**: Bundles `wl-clipboard` and `xclip` in PATH for automatic route plotting clipboard integration.
- **Voice & TTS**: Bundles `piper-tts` for local neural speech alerts and text-to-speech without extra setup.
- **In-Game Overlay**: Includes `ed-outrider-overlay` wrapper with PyQt6 support.
- **NixOS Module**: Includes `nixosModules.default` with a systemd user service (`ed-outrider.service`) started automatically with your graphical session. Supports `listen = "lan"` with firewall restricted to private IPv4 and link-local/ULA IPv6 (prevents Internet IPv6 exposure), and `user` option (`ConditionUser`).
- **Home Manager Module**: Includes `homeManagerModules.default` (and `homeModules.default`) to configure the user service per-user cleanly.

## Usage

### Run directly with `nix run`

Run the local web server:
```bash
nix run
```

Run the in-game overlay:
```bash
nix run .#overlay
```

### NixOS Module (`nixosModules.default`)

Import `ed-outrider.nixosModules.default` in your NixOS configuration:

```nix
{
  services.ed-outrider = {
    enable = true;
    port = 8025; # default: 8025

    # Listen scope: "localhost" (default, 127.0.0.1 only) or "lan"
    # When set to "lan", binds to 0.0.0.0 and opens the firewall ONLY for
    # private IPv4 networks and link-local/ULA IPv6 (never exposed to the Internet).
    listen = "lan";

    # Optional: restrict systemd user service to this user (via ConditionUser)
    # Useful on multi-user systems to prevent port conflicts and unwanted background services
    user = "alice";
  };
}
```

### Home Manager Module (`homeManagerModules.default` / `homeModules.default`)

Import `ed-outrider.homeManagerModules.default` in your Home Manager configuration:

```nix
{
  services.ed-outrider = {
    enable = true;
    port = 8025;
    listen = "localhost"; # or "lan" to listen on 0.0.0.0
  };
}
```
