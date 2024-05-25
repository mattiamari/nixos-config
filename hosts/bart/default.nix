{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./desktop.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  networking.hostName = "bart";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Rome";


  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = lib.mkForce "it";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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
    tmux
    helix
    nil
    git
    htop
    btop
    gdu
    pinentry-curses
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };

  virtualisation.oci-containers.backend = "podman";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old";
  };

  system.stateVersion = "23.11";
}
