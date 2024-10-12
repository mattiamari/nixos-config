{ config, pkgs, lib, pkgsUnstable, catppuccin, ... }:
{
  imports = [
    catppuccin.homeManagerModules.catppuccin
  ];
  
  programs.home-manager.enable = true;

  home = {
    username = "work";
    homeDirectory = "/home/work";

    stateVersion = "24.05";

    packages =
    let
      idea = pkgsUnstable.jetbrains.idea-ultimate.override { vmopts = "-Xmx8G"; };
    in
    with pkgs; [
      openfortivpn
      idea
      podman-compose
      podman-tui
      dive
    ];

    sessionVariables = {
      COLORTERM = "truecolor";
    };
  };

  # https://nix.catppuccin.com/options/home-manager-options.html
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "teal";
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "cloud";
    };
  };

  programs.eza.enable = true; # `ls` alternative
  programs.fzf.enable = true; # fuzzy finder
  programs.fd.enable = true; # `find` alternative
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true; # smart `cd` command
  programs.bat.enable = true; # nicer `cat`
  programs.lazygit.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = false;
    
    settings = {
      editor = {
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";

    extraConfig = ''
      set-option -sg escape-time 10
      set-option -g focus-events on
    '';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
