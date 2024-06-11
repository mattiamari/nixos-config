{ config, pkgs, lib, pkgsUnstable, catppuccin, pkgsIdea, ... }:
{
  imports = [
    catppuccin.homeManagerModules.catppuccin
  ];
  
  programs.home-manager.enable = true;

  nixpkgs.overlays = [
    (final: prev: { jetbrains.idea-ultimate = pkgsIdea.jetbrains.idea-ultimate.override { vmopts = "-Xmx16000m"; }; })
  ];
  
  home = {
    username = "work";
    homeDirectory = "/home/work";

    stateVersion = "24.05";

    packages = with pkgs; [
      openfortivpn
      jdt-language-server
      jetbrains.idea-ultimate
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

  programs.eza.enable = true;
  programs.fzf.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;
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
    package = pkgsUnstable.neovim-unwrapped;

    plugins = with pkgsUnstable.vimPlugins; [
      nvim-jdtls
    ];
  };
}
