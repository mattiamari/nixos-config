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
      size = 24;
    };
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "catppuccin";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    
    settings = {
      theme = "catppuccin_macchiato";

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

  gtk = {
    enable = true;
    theme = {
      name = "vimix-dark-doder";
      package = pkgs.vimix-gtk-themes;
    };
    iconTheme = {
      name = "Vimix-Doder";
      package = pkgs.vimix-icon-theme;
    };
  };

  qt = {
    enable = true;
  };
}
