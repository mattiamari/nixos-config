{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ../features/podman.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "work";
  wsl.interop.includePath = false;

  users.users.work = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  environment.systemPackages = with pkgs; [
    scc
  ];

  system.stateVersion = "23.11";
}
