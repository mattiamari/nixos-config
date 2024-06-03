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
      gimp
    ];

    sessionVariables = {
      # for hyprland
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };

  xdg = {
    enable = true;

    desktopEntries = {
      # does not work on wayland. force running on xwayland
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

    # https://wiki.hyprland.org/0.40.0/Configuring/Variables/
    settings = {
      monitor = "HDMI-A-2,3840x2160@60,auto,1.0,bitdepth,10";
      
      input = {
        kb_layout = "it";
        numlock_by_default = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
      };

      decoration = {
        rounding = 10;
      };

      animations = {
        enabled = true;
      };

      dwindle = {
        # whether to apply gaps when there is only one window on a workspace (default: disabled - 0) no border - 1, with border - 2
        no_gaps_when_only = 1;
      };

      misc = {
        # force "hyprland logo" wallpaper
        force_default_wallpaper = 0;
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

        # float and pin (i.e. picture in picture that follows you across workspaces)
        "$mod, P, toggleFloating"
        "$mod, P, pin, active"
        "$mod, P, fakefullscreen"
      
        # move focus with arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # switch to prev/next workspace
        "$mod ALT, left, workspace, e-1"
        "$mod ALT, right, workspace, e+1"

        # volume control
        ",code:123, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ",code:122, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ",code:121, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"

        # brightness control
        ",code:233, exec, ddccontrol -r 0x10 -W +5 dev:/dev/i2c-8"
        ",code:232, exec, ddccontrol -r 0x10 -W -5 dev:/dev/i2c-8"

        # screenshots
        ",Print,exec,${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
      ]
        # switch workspaces
        ++ builtins.genList (n: "$mod, ${toString (n+1)}, workspace, ${toString (n+1)}") 9
        
        # move windows between workspaces
        ++ builtins.genList (n: "$mod SHIFT, ${toString (n+1)}, movetoworkspace, ${toString (n+1)}") 9;

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
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

  programs.lazygit.enable = true;

  services.syncthing = {
    enable = true;
    # TODO waybar has no tray
    tray.enable = false;
  };

}
