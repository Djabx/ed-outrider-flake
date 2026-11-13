# ED-Outrider Nix Flake

Nix flake packaging for [ED-Outrider](https://github.com/weslocke/ED-Outrider), an exploration companion and cockpit assistant for Elite Dangerous.

## Features

- **XDG Compliance**: Patched to store database, logs and settings in `$XDG_DATA_HOME` (`~/.local/share/ed-outrider`) and `$XDG_CONFIG_HOME` (`~/.config/ed-outrider`) instead of the read-only Nix store.
- **Wayland & X11 Clipboard**: Bundles `wl-clipboard` and `xclip` in PATH for automatic route plotting clipboard integration.
- **In-Game Overlay**: Includes `ed-outrider-overlay` wrapper with PyQt6 support.
- **NixOS Module**: Includes `nixosModules.default` with a systemd user service (`ed-outrider.service`) started automatically with your graphical session.

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

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ed-outrider = {
      url = "git+https://git.badez.eu/ed/ed-outrider-flake.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ed-outrider, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ed-outrider.nixosModules.default
        {
          services.ed-outrider = {
            enable = true;
            port = 8025;
            openFirewall = false; # Set to true to access web UI from phone/tablet on LAN
          };
        }
      ];
    };
  };
}
```
