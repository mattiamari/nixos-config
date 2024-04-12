{ pkgs, config, ... }:

{
  console.keyMap = "it";

  # Enable NetworkManager so that `nmtui` can be used to connect to WiFi
  networking.wireless.enable = false;
  networking.networkmanager.enable=true;
  
  programs.zsh.enable = true;
  programs.tmux = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    smartmontools
    exfatprogs
    testdisk
    gdu
    btop
    stress-ng
    helix
  ];
}
