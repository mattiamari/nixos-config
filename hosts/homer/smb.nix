{ ... }:
let
  myConfig = import ./common.nix;
in
{
  services.samba = {
    enable = true;
    openFirewall = true;
    enableNmbd = true;

    # https://wiki.archlinux.org/title/Samba#Restrict_protocols_for_better_security
    # https://wiki.archlinux.org/title/Samba#Improve_throughput
    extraConfig = ''
      guest account = nobody
      map to guest = bad user

      server min protocol = SMB3
      server max protocol = SMB3
      server smb encrypt = required
      
      load printers = no

      deadtime = 30
      use sendfile = yes
    '';

    shares = {
      storage = {
        path = "/media/storage";
        writable = true;
        browseable = true;
        "guest ok" = false;
        "valid users" = myConfig.adminUser;
      };
      family = {
        path = "/media/storage/famiglia";
        writable = true;
        browseable = true;
        "guest ok" = false;
        "valid users" = "@family"; # group "family"
      };
      media = {
        path = "/media/storage/media";
        "read only" = true;
        browseable = true;
        "guest ok" = true;
      };
      public = {
        path = "/media/storage/public";
        writable = true;
        browseable = true;
        "guest ok" = true;
      };
    };
  };
}
