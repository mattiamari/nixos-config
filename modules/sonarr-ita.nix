{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.sonarrIta;
  configDir = "/var/lib/sonarrIta/.config/NzbDrone";
  configFilePath = "${configDir}/config.xml";
  configFile = pkgs.writeText "config.xml" ''
    <Config>
      <Port>${toString cfg.port}</Port>
    </Config>
  '';
  preStart = pkgs.writeShellScript "sonarrIta-prestart" ''
    if [[ -f ${configFilePath} ]]; then
      sed -i 's|<Port>.*</Port>|<Port>${toString cfg.port}</Port>|g' ${configFilePath}
    else
      install --mode 600 --owner=$USER ${configFile} ${configFilePath}
    fi
  '';
in
{
  options = {
    services.sonarrIta = {
      enable = mkEnableOption (lib.mdDoc "Sonarr ITA");

      package = mkOption {
        default = pkgs.sonarr;
        defaultText = literalExpression "pkgs.sonarr";
        description = lib.mdDoc "Sonarr package to use.";
        type = types.package;
      };

      port = mkOption {
        type = types.port;
        description = lib.mdDoc "Port for the web server to listen on";
      };

      user = mkOption {
        type = types.str;
        description = lib.mdDoc "User account under which Sonarr runs.";
      };

      group = mkOption {
        type = types.str;
        description = lib.mdDoc "Group under which Sonarr runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.sonarrIta = {
      description = "Sonarr ITA";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "sonarrIta";
        StateDirectoryMode = "0700";
        Umask = "0007";
        ExecStartPre = "!${preStart}";
        ExecStart = "${cfg.package}/bin/NzbDrone -nobrowser -data='${configDir}'";
        Restart = "on-failure";
      };
    };
  };
}
