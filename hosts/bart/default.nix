{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./desktop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages;

  boot.tmp.useTmpfs = true;

  # Prevent restart on kernel panic
  boot.kernelParams = [
    "panic=0"
  ];

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
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [ 48000 88200 96000 176400 192000 352800 384000 ];
        };
      };
    };
  };

  services.ddccontrol.enable = true;

  services.udisks2.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  users.users.mattia = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
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
    shadow # for rootless podman
  ];

  # required for easyeffects
  programs.dconf.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # services.flatpak.enable = true;

  # Keyboard remapping
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        devices = [
          "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse"
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
            caps
          )

          (defalias
            escctrl (tap-hold 150 150 esc lctrl)
          )

          (deflayer base
            @escctrl
          )
        '';
      };
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.backend = "podman";
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  system.stateVersion = "23.11";
}
