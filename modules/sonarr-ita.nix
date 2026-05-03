{
  config,
  pkgs,
  lib,
  ...
}:

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
      enable = lib.mkEnableOption "Sonarr ITA";

      package = lib.mkOption {
        default = pkgs.sonarr;
        defaultText = lib.literalExpression "pkgs.sonarr";
        description = "Sonarr package to use.";
        type = lib.types.package;
      };

      port = lib.mkOption {
        type = lib.types.port;
        description = "Port for the web server to listen on";
      };

      user = lib.mkOption {
        type = lib.types.str;
        description = "User account under which Sonarr runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        description = "Group under which Sonarr runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
        UMask = "0007";
        ExecStartPre = "!${preStart}";
        ExecStart = "${cfg.package}/bin/NzbDrone -nobrowser -data='${configDir}'";
        Restart = "on-failure";
      };
    };

    systemd.tmpfiles.rules = [
      "d '${configDir}' 0700 ${cfg.user} ${cfg.group}"
    ];
  };
}
