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
      description = "Listen scope: 'localhost' (127.0.0.1) or 'lan' (0.0.0.0).";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--radius" "50" ];
      description = "Extra arguments passed to ed-outrider.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.ed-outrider = {
      Unit = {
        Description = "ED-Outrider exploration companion for Elite Dangerous";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/ed-outrider --host ${if cfg.listen == "lan" then "0.0.0.0" else "127.0.0.1"} --port ${toString cfg.port} ${lib.escapeShellArgs cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
