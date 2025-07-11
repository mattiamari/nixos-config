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

  # systemd.tmpfiles.rules = [
  #   "d ${dataDir} 0750 filebrowser filebrowser -"
  #   "d ${dataDir}/media 0750 filebrowser filebrowser -"
  # ];
  
  systemd.mounts = [
    {
      what = "/media/storage/media";
      where = "${dataDir}/media";
      type = "none";
      options = "bind";
      requires = [ "media-storage-media.mount" "media-storage-filebrowser.mount" ];
      after = [ "media-storage-media.mount" "media-storage-filebrowser.mount" ];
      wantedBy = [ "multi-user.target" ];
    }
  ];
}
