{ config, pkgs, pkgsUnstable, ... }:
{
  programs.home-manager.enable = true;

  home = {
    username = "mattia";
    homeDirectory = "/home/mattia";

    stateVersion = "23.11";

    packages = with pkgs; [
      mpv
      vlc
      pkgsUnstable.obsidian
      calibre
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.vimix-cursors;
      name = "Vimix Cursors";
      size = 36;
    };
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "cloud";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    
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

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "teal";
  };

  gtk = {
    enable = true;
  };

  qt = {
    enable = true;
  };

}
