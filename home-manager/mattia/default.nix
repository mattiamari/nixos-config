{ config, pkgs, pkgsUnstable, catppuccin, ... }:
{
  imports = [
    catppuccin.homeManagerModules.catppuccin
  ];
  
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

    sessionVariables = {
      # to make cursor visible in hyprland
      WLR_NO_HARDWARE_CURSORS = "1";
    };
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

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      # exec-once = "hyprpaper";
      
      monitor = "HDMI-A-2,3840x2160@60,auto,1.0,bitdepth,10";
      
      input = {
        kb_layout = "it";
      };

      animations = {
        enabled = true;
      };

      misc = {
        # disable anime wallpaper
        force_default_wallpaper = false;
      };

      "$mod" = "SUPER";

      bind = [
        "$mod, Q, exec, alacritty"
        "$mod, E, exec, thunar"
        "$mod, R, exec, rofi -show combi"
        # "$mod, W, exec, rofi -show calc -modi calc -no-show-match -no-sort"
        "$mod, C, killactive"
        "$mod, F, fullscreen, 1"
        "$mod, M, exit"
      
        # move focus with arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
      ]
        # switch workspaces
        ++ builtins.genList (n: "$mod, ${toString (n+1)}, workspace, ${toString (n+1)}") 9
        
        # move windows between workspaces
        ++ builtins.genList (n: "$mod SHIFT, ${toString (n+1)}, movetoworkspace, ${toString (n+1)}") 9;

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
    };
  };

  services.hyprpaper =
  let
    wall1 = "~/Pictures/wallpapers/yLXrKS.jpg";
  in {
    enable = true;
    settings = {
      splash = false;
      ipc = "on";

      preload = [
        wall1
      ];

      wallpaper = [
        ",${wall1}"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    catppuccin.mode = "createLink";
    style = ./waybar.css;
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
      # TODO bugged upstream
      # pkgs.rofi-calc
    ];

    # Get possible values with `rofi -dump-config`
    extraConfig = {
      modes = "drun,window,ssh";
      combi-modes = "window,drun,ssh";
      show-icons = true;
      terminal = "alacritty";
      combi-display-format = " <span weight='light'>{mode}</span> {text}";
    };
  };

  services.syncthing = {
    enable = true;
    # TODO waybar has no tray
    tray.enable = false;
  };

}
