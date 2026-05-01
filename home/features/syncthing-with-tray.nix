{ pkgs, lib, ... }:
{

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  # Fix "the system tray is not currently available" message from syncthing tray
  systemd.user.services.syncthingtray.Service.ExecStartPre =
    lib.mkForce "${pkgs.coreutils}/bin/sleep 3";
  systemd.user.services.syncthingtray.Service.ExecStart =
    lib.mkForce "${pkgs.syncthingtray}/bin/syncthingtray --wait";
  systemd.user.services.syncthingtray.Unit.After = lib.mkForce "waybar.service";

}
