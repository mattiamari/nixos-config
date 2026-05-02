{ pkgs, lib, ... }:
let
  helpFile = pkgs.writeText "HELP.md" ''
    # Rescue USB - Available Commands

    ## Disk & Filesystem
    - `lsblk`, `fdisk -l`           list block devices and partitions
    - `testdisk`                    partition recovery and repair
    - `ddrescue`                    sector-level cloning for failing drives
    - `partclone.*`                 clone/restore partitions excluding free space (partclone.ntfs, .ext4, etc.)
    - `ntfsclone`                   clone NTFS partitions excluding free space
    - `fsck`, `e2fsck`              filesystem check and repair
    - `dosfsck`                     FAT/FAT32 filesystem check
    - `mkfs.*`                      format partitions
    - `smartctl -a /dev/sdX`        S.M.A.R.T. disk health info
    - `hdparm`                      disk parameters and benchmarks

    ## System Inspection
    - `lspci`                       list PCI devices
    - `lsusb`                       list USB devices
    - `lshw`                        full hardware inventory
    - `dmidecode`                   BIOS/DMI info (RAM, serial numbers)
    - `hwinfo`                      detailed hardware probe
    - `btop`, `htop`                process and resource monitor

    ## Network
    - `nmtui`                       TUI to connect to WiFi
    - `ip a`                        show network interfaces
    - `iperf3`                      bandwidth testing

    ## Boot & EFI
    - `efibootmgr`                  read and edit EFI boot entries
    - `grub-install`                reinstall GRUB bootloader

    ## File Operations
    - `rsync`                       copy/sync data off a dying system
    - `7z`                          compress/extract (7z, zip, tar, gz, bz2, xz, zst, rar...)
    - `gdu`                         disk usage viewer
    - `yazi`                        terminal file manager

    ## Stress Testing
    - `stress-ng`                   stress test CPU, RAM, disk

    ## General
    - `bat`                         syntax-highlighted file viewer
    - `rg`                          ripgrep - fast file content search
    - `fd`                          fast file finder
    - `fzf`                         fuzzy finder
    - `tmux`                        terminal multiplexer (useful for long recovery sessions)
  '';
in
{
  imports = [
    ../common
  ];

  boot.loader.grub.memtest86.enable = true;
  isoImage.appendToMenuLabel = "";

  services.xserver.xkb = lib.mkForce {
    layout = "it";
    variant = "";
  };
  console.keyMap = lib.mkForce "it";

  services.getty.autologinUser = "root";
  users.users.root.shell = pkgs.zsh;

  # Enable NetworkManager so that `nmtui` can be used to connect to WiFi
  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce true;

  environment.systemPackages = with pkgs; [
    testdisk
    ddrescue
    smartmontools
    hdparm
    dosfstools
    exfatprogs
    ntfsprogs
    partclone
    partclone-utils

    pciutils
    usbutils
    lshw
    dmidecode
    hwinfo

    iperf3

    efibootmgr
    grub2

    stress-ng

    rsync
    p7zip
    gdu
  ];

  systemd.tmpfiles.rules = [
    "L+ /root/HELP.md - - - - ${helpFile}"
  ];

  system.stateVersion = "26.05";
}
