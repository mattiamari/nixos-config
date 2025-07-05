{ ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    enableNmbd = true;

    settings = {
      # https://wiki.archlinux.org/title/Samba#Restrict_protocols_for_better_security
      # https://wiki.archlinux.org/title/Samba#Improve_throughput
      global = {
        "guest account" = "nobody";
        "map to guest" = "bad user";

        "server min protocol" = "SMB3";
        "server max protocol" = "SMB3";
        "server smb encrypt" = "required";
      
        "load printers" = "no";

        deadtime = 30;
        "use sendfile" = "yes";
      };
      
      cdrom = {
        path = "/mnt/cdrom";
        writable = false;
        browseable = true;
        "guest ok" = true;
      };
    };
  };

  fileSystems."/mnt/cdrom" = {
    device = "/dev/sr0";
    options = [
      "auto"
      "x-systemd.automount"
    ];
  };

  # systemd.mounts = [{
  #   what = "/dev/sr0";
  #   where = "/mnt/cdrom";
  # }];

  # systemd.automounts = [{
  #   where = "/mnt/cdrom";
  #   wantedBy = [ "multi-user.target" ];
  # }];
}
