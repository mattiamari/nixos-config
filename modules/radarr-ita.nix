{ config, pkgs, lib, ... }:

with lib;

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
      enable = mkEnableOption (lib.mdDoc "Radarr ITA");

      package = mkOption {
        description = lib.mdDoc "Radarr package to use";
        default = pkgs.radarr;
        defaultText = literalExpression "pkgs.radarr";
        example = literalExpression "pkgs.radarr";
        type = types.package;
      };

      port = mkOption {
        type = types.port;
        description = lib.mdDoc "Port for the web server to listen on";
      };
      
      user = mkOption {
        type = types.str;
        description = lib.mdDoc "User account under which Radarr runs.";
      };

      group = mkOption {
        type = types.str;
        description = lib.mdDoc "Group under which Radarr runs.";
      };
    };
  };

  config = mkIf cfg.enable {
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
        Umask = "0007";
        ExecStartPre = "!${preStart}";
        ExecStart = "${cfg.package}/bin/Radarr -nobrowser -data='${configDir}'";
        Restart = "on-failure";
      };
    };
  };
}
