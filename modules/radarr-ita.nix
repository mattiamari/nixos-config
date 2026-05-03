{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.radarrIta;
  configDir = "/var/lib/radarrIta/.config/Radarr";
  configFilePath = "${configDir}/config.xml";
  configFile = pkgs.writeText "config.xml" ''
    <Config>
      <Port>${toString cfg.port}</Port>
    </Config>
  '';
  preStart = pkgs.writeShellScript "radarrIta-prestart" ''
    if [[ -f ${configFilePath} ]]; then
      sed -i 's|<Port>.*</Port>|<Port>${toString cfg.port}</Port>|g' ${configFilePath}
    else
      install --mode 600 --owner=$USER ${configFile} ${configFilePath}
    fi
  '';
in
{
  options = {
    services.radarrIta = {
      enable = lib.mkEnableOption "Radarr ITA";

      package = lib.mkOption {
        description = "Radarr package to use";
        default = pkgs.radarr;
        defaultText = lib.literalExpression "pkgs.radarr";
        example = lib.literalExpression "pkgs.radarr";
        type = lib.types.package;
      };

      port = lib.mkOption {
        type = lib.types.port;
        description = "Port for the web server to listen on";
      };

      user = lib.mkOption {
        type = lib.types.str;
        description = "User account under which Radarr runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        description = "Group under which Radarr runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.radarrIta = {
      description = "Radarr ITA";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "radarrIta";
        StateDirectoryMode = "0700";
        UMask = "0007";
        ExecStartPre = "!${preStart}";
        ExecStart = "${cfg.package}/bin/Radarr -nobrowser -data='${configDir}'";
        Restart = "on-failure";
      };
    };

    systemd.tmpfiles.rules = [
      "d '${configDir}' 0700 ${cfg.user} ${cfg.group}"
    ];
  };
}
