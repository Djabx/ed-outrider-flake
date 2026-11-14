self:
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.ed-outrider;
in
{
  options.services.ed-outrider = {
    enable = lib.mkEnableOption "ED-Outrider exploration companion for Elite Dangerous";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "inputs.ed-outrider.packages.\${pkgs.stdenv.hostPlatform.system}.default";
      description = "Package to use for ED-Outrider.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8025;
      description = "Port to serve on.";
    };

    listen = lib.mkOption {
      type = lib.types.enum [ "localhost" "lan" ];
      default = "localhost";
      description = "Listen scope: 'localhost' (127.0.0.1 only) or 'lan' (0.0.0.0 with firewall restricted to private IPv4 and link-local/ULA IPv6 networks).";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--radius" "50" ];
      description = "Extra arguments passed to ed-outrider.";
    };

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Restrict the systemd user service to this specific user (via ConditionUser).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf (cfg.listen == "lan") {
      extraCommands = ''
        iptables -w -A nixos-fw -p tcp --dport ${toString cfg.port} -s 192.168.0.0/16 -j nixos-fw-accept
        iptables -w -A nixos-fw -p tcp --dport ${toString cfg.port} -s 10.0.0.0/8 -j nixos-fw-accept
        iptables -w -A nixos-fw -p tcp --dport ${toString cfg.port} -s 172.16.0.0/12 -j nixos-fw-accept
        ip6tables -w -A nixos-fw -p tcp --dport ${toString cfg.port} -s fe80::/10 -j nixos-fw-accept
        ip6tables -w -A nixos-fw -p tcp --dport ${toString cfg.port} -s fc00::/7 -j nixos-fw-accept
      '';
      extraStopCommands = ''
        iptables -w -D nixos-fw -p tcp --dport ${toString cfg.port} -s 192.168.0.0/16 -j nixos-fw-accept 2>/dev/null || true
        iptables -w -D nixos-fw -p tcp --dport ${toString cfg.port} -s 10.0.0.0/8 -j nixos-fw-accept 2>/dev/null || true
        iptables -w -D nixos-fw -p tcp --dport ${toString cfg.port} -s 172.16.0.0/12 -j nixos-fw-accept 2>/dev/null || true
        ip6tables -w -D nixos-fw -p tcp --dport ${toString cfg.port} -s fe80::/10 -j nixos-fw-accept 2>/dev/null || true
        ip6tables -w -D nixos-fw -p tcp --dport ${toString cfg.port} -s fc00::/7 -j nixos-fw-accept 2>/dev/null || true
      '';
    };

    systemd.user.services.ed-outrider = {
      description = "ED-Outrider exploration companion for Elite Dangerous";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      unitConfig = lib.mkIf (cfg.user != null) {
        ConditionUser = cfg.user;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/ed-outrider --host ${if cfg.listen == "lan" then "0.0.0.0" else "127.0.0.1"} --port ${toString cfg.port} ${lib.escapeShellArgs cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
