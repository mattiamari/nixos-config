{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.filebrowser;
  defaultUser = "filebrowser";
  defaultGroup = "filebrowser";
in
{
  options.services.filebrowser = {
    enable = mkEnableOption (mdDoc "FileBrowser");

    package = mkOption {
      type = types.package;
      default = pkgs.filebrowser;
    };

    port = mkOption {
      type = types.port;
      default = 8080;
    };

    user = mkOption {
      type = types.str;
      default = defaultUser;
    };

    group = mkOption {
      type = types.str;
      default = defaultGroup;
    };
  };

  config = mkIf cfg.enable {
  
    systemd.services.filebrowser = {
      description = "FileBrowser";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        "FB_ADDRESS" = "127.0.0.1";
        "FB_PORT" = toString cfg.port;
        "FB_BASEURL" = "/";
        "FB_ROOT" = "/var/lib/filebrowser/data";
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "/var/lib/filebrowser";
        StateDirectory = "filebrowser";
        StateDirectoryMode = "0700";
        ConfigurationDirectory = "filebrowser";
        ConfigurationDirectoryMode = "0700";
        UMask = "0007";
        ExecStart = "${cfg.package}/bin/filebrowser";
      };
    };

    systemd.tmpfiles.rules = [
      "d '/var/lib/filebrowser/data' 0750 ${cfg.user} ${cfg.group}"
    ];

    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = {};
    };

    
  };
}
