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
      pkgsUnstable.jellyfin-media-player
    ];
  };

  xdg = {
    enable = true;

    desktopEntries = {
      jellyfinmediaplayerxcb = {
        name = "Jellyfin Media Player XCB";
        exec = "jellyfinmediaplayer --platform xcb";
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

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    plugins = [
      pkgs.rofi-calc
    ];

    # Get possible values with `rofi -dump-config`
    extraConfig = {
      modes = "drun,window,calc,ssh";
      combi-modes = "window,drun,ssh";
      show-icons = true;
      terminal = "alacritty";
      combi-display-format = " <span weight='light'>{mode}</span> {text}";
    };
  };

}
