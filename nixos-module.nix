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

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address to serve on.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--radius" "50" ];
      description = "Extra arguments passed to ed-outrider.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the port in the firewall (useful if connecting from tablet/phone).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.user.services.ed-outrider = {
      description = "ED-Outrider exploration companion for Elite Dangerous";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/ed-outrider --host ${cfg.host} --port ${toString cfg.port} ${lib.escapeShellArgs cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
