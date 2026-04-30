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

  environment.systemPackages = with pkgs; [
    scc
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "23.11";
}
