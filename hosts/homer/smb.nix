{ ... }:
let
  myConfig = import ./common.nix;
in
{
  services.samba = {
    enable = true;
    openFirewall = true;
    enableNmbd = true;
    extraConfig = ''
      guest account = nobody
      map to guest = bad user
      server min protocol = SMB3
      server smb encrypt = desired
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
        path = "/media/storage/family";
        writable = true;
        browseable = true;
        "guest ok" = false;
        "valid users" = "@family";
      };
      media = {
        path = "/media/storage/media";
        "read only" = true;
        browseable = true;
        "guest ok" = true;
      };
    };
  };
}
