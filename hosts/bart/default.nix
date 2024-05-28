{ config, lib, pkgs, homeManager, ... }:

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

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
  };

  users.users.mattia = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    pinentry-curses
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };

  virtualisation.oci-containers.backend = "podman";

  system.stateVersion = "23.11";
}
