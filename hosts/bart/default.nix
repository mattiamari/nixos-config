{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../common
    ../features/nvidia-legacy.nix
    ../features/desktop-environment.nix
    ../features/sound.nix
    ../features/hw-keyboard-lofree.nix
    ../features/betaflight.nix
    ../features/podman.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    memtest86.enable = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.tmp.useTmpfs = true;

  # Prevent restart on kernel panic
  boot.kernelParams = [
    "panic=0"
  ];

  fileSystems."/".options = [
    "noatime"
    "nodiratime"
  ];
  services.fstrim.enable = true;

  networking.hostName = "bart";
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;
    extraInputRules =
      # nextjs dev server + backend
      ''
        ip saddr 192.168.0.0/24 tcp dport 3000 accept
        ip saddr 192.168.0.0/24 tcp dport 8080 accept
      '';
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.ddccontrol.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  users.users.mattia = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "audio"
      "dialout" # serial port access for betaflight configurator
    ];
    shell = pkgs.zsh;
  };

  users.users.work = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAXc/DBxDckVOYmMtlA3cAowsgW7v5FyYknfmg51It+"
    ];
  };

  environment.systemPackages = with pkgs; [
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  services.flatpak.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  system.stateVersion = "23.11";
}
