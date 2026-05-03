{ config, pkgs, ... }:
{

  users.users.${config.homeserver.adminUser} = {
    isNormalUser = true;
    description = "Admin";
    uid = 1000;
    group = config.homeserver.adminUser;
    extraGroups = [
      config.homeserver.adminUser
      "networkmanager"
      "wheel"
      "family"
      "mediaserver"
      "syncthing"
    ];
    packages = [ ];
    shell = pkgs.zsh;
    # linger = true;
  };
  users.groups.${config.homeserver.adminUser} = {
    gid = 1000;
  };

  users.users.family = {
    isNormalUser = true;
    description = "family";
    group = "family";
    uid = 1001;
  };
  users.groups.family = {
    gid = 1001;
  };

  users.users.mediaserver = {
    isSystemUser = true;
    group = "mediaserver";
    uid = 993;
  };
  users.groups.mediaserver = {
    gid = 993;
  };

}
