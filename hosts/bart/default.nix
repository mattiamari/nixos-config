{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./desktop.nix
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

  # Fix lofree keyboard FN keys
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

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

  security.rtkit.enable = true; # allows pipewire to get realtime priority
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.rate" = 44100;
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
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

  # betaflight access to STM DFU
  services.udev = {
    enable = true;
    packages = [
      (pkgs.writeTextDir "lib/udev/rules.d/70-stm32-dfu.rules" ''
        # DFU (Internal bootloader for STM32 and AT32 MCUs)
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"
      '')
    ];
  };

  users.users.mattia = {
    isNormalUser = true;
    extraGroups = [
      "wheel" "networkmanager" "libvirtd" "audio"
      "dialout" # serial port access for betaflight configurator
    ];
    shell = pkgs.zsh;
  };

  users.users.work = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
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

  services.flatpak.enable = true;

  # Keyboard remapping
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        devices = [
          # Empty list means "apply to all keyboards"
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

  services.ollama = {
    enable = false;
    package = pkgs.ollama-cuda;
    acceleration = "cuda";
  };

  services.open-webui = {
    enable = false;
    package = pkgs.open-webui;
    port = 9123;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      WEBUI_AUTH = "False";
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
