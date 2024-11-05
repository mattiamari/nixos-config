{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "work";
  wsl.interop.includePath = false;

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    btop
    curl
    wget
    git
    scc
  ];

  programs.zsh = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.tmux.enable = true;

  system.stateVersion = "23.11";
}
