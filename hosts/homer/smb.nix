{ ... }:
let
  myConfig = import ./common.nix;
in
{
  services.samba = {
    enable = true;
    openFirewall = true;
    nmbd.enable = true;

    # https://wiki.archlinux.org/title/Samba#Restrict_protocols_for_better_security
    # https://wiki.archlinux.org/title/Samba#Improve_throughput
    settings = {
      global = {
        "invalid users" = ["root"];
        "passwd program" = "/run/wrappers/bin/passwd %u";
        security = "user";

        "guest account" = "nobody";
        "map to guest" = "never";

        "server min protocol" = "SMB3";
        "server max protocol" = "SMB3";
        "server smb encrypt" = "required";

        "load printers" = "no";

        "deadtime" = "30";
        "use sendfile" = "yes";
      };

      storage = {
        path = "/media/storage";
        writable = "yes";
        browseable = "yes";
        "guest ok" = "no";
        "valid users" = myConfig.adminUser;
      };
      family = {
        path = "/media/storage/famiglia";
        writable = "yes";
        browseable = "yes";
        "guest ok" = "no";
        "valid users" = "@family"; # group "family"
      };
      media = {
        path = "/media/storage/media";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      public = {
        path = "/media/storage/public";
        writable = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
    };
  };
}
