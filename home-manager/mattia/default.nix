{ config, pkgs, lib, pkgsUnstable, catppuccin, ... }:
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
      xournalpp
      spotify
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

  # https://nix.catppuccin.com/options/home-manager-options.html
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

    # https://wiki.hyprland.org/0.40.0/Configuring/Variables
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

      debug = {
        disable_logs = true;
      };

      "$mod" = "SUPER";

      # https://wiki.hyprland.org/0.40.0/Configuring/Dispatchers
      bind = [
        "$mod, Q, exec, alacritty"
        "$mod, E, exec, thunar"
        "$mod, SPACE, exec, rofi -show combi"
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

        # move window
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # resize window
        "$mod CONTROL, left, resizeactive, -10% 0%"
        "$mod CONTROL, right, resizeactive, 10% 0%"
        "$mod CONTROL, up, resizeactive, 0% -10%"
        "$mod CONTROL, down, resizeactive, 0% 10%"

        # switch to prev/next workspace
        "$mod ALT, left, workspace, e-1"
        "$mod ALT, right, workspace, e+1"

        # volume control
        ",code:123, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",code:122, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",code:121, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

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

    # https://github.com/Alexays/Waybar/wiki/Configuration
    settings = {
      main = {
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "clock" "tray" ];

        "hyprland/workspaces" = {
          active-only = false;
        };

        clock = {
          tooltip-format = "{calendar}";
          format-alt = "{:%Y-%m-%d %H:%M}";
        };

        cpu = {
          format = "  {usage}%  {avg_frequency}Ghz";
          on-click = "${pkgs.alacritty}/bin/alacritty -e '${pkgs.btop}/bin/btop'";
        };

        memory = {
          format = "  {}%";
        };

        temperature = {
          format = " {temperatureC}°C";
          hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
          critical-threshold = 86;
        };

        network = {
          format-ethernet = "󰈀  {ipaddr}";
          format-wifi = "󰖩 {essid} ({signalStrength}%)";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon}  {volume}%  {format_source}";
          format-muted = "󰝟 {format_source}";
          format-source = "󰍬 {volume}%";
          format-source-muted = "󰍭";
          format-icons = {
            default = [ "" "" ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        tray = {
          icon-size = 20;
        };
      };
    };
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
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;

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
    tray.enable = true;
  };

  # Fix "the system tray is not currently available" message from syncthing tray
  systemd.user.services.syncthingtray.Service.ExecStartPre = lib.mkForce "${pkgs.coreutils}/bin/sleep 3";
  systemd.user.services.syncthingtray.Service.ExecStart = lib.mkForce "${pkgs.syncthingtray}/bin/syncthingtray --wait";
  systemd.user.services.syncthingtray.Unit.After = lib.mkForce "waybar.service";
  systemd.user.services.syncthingtray.Unit.Requires = lib.mkForce "waybar.service";

  services.easyeffects.enable = true;
}
