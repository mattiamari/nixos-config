{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./desktop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  boot.tmp.useTmpfs = true;

  fileSystems."/".options = [ "noatime" "nodiratime" ];
  services.fstrim.enable = true;

  networking.hostName = "bart";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
  };

  services.ddccontrol.enable = true;

  users.users.mattia = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  users.users.work = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAXc/DBxDckVOYmMtlA3cAowsgW7v5FyYknfmg51It+"
    ];
  };

  environment.systemPackages = with pkgs; [
    pinentry-curses
  ];

  # required for easyeffects
  programs.dconf.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  services.flatpak.enable = true;

  virtualisation.oci-containers.backend = "podman";

  system.stateVersion = "23.11";
}
