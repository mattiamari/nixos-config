{config, ...}:
let
  dataDir = "/media/storage/filebrowser";
in
{
  services.filebrowser = {
    enable = true;
    settings = {
      port = 7000;
      address = "127.0.0.1";
      database = "/var/lib/filebrowser/filebrowser.db";
      root = dataDir;
    };
    user = "filebrowser";
    group = "filebrowser";
  };

  myCaddy.publicServices.filebrowser = {
    port = config.services.filebrowser.settings.port;
  };

  users.users.filebrowser = {
    isSystemUser = true;
    group = "filebrowser";
    extraGroups = [
      "mediaserver"
    ];
    uid = 992;
  };
  users.groups.filebrowser = {
    gid = 990;
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 filebrowser filebrowser -"
    "d ${dataDir}/media 0750 filebrowser filebrowser -"
  ];

  fileSystems."${dataDir}/media" = {
    device = "/media/storage/media";
    fsType = "none";
    options = [ "bind" ];
  };
}
