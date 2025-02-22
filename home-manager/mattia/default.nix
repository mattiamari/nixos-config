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
      pkgsUnstable.supersonic-wayland
      pkgsUnstable.obsidian
      calibre
      pkgsUnstable.jellyfin-media-player
      gimp
      xournalpp
      okular
      pkgsUnstable.libreoffice-fresh
      spotify
      sshfs
      pkgsUnstable.telegram-desktop
      brave
    ];

    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 7d";
  };

  xdg = {
    enable = true;

    desktopEntries = {
      # https://github.com/jellyfin/jellyfin-media-player/issues/165
      jellyfinmediaplayerxcb = {
        name = "Jellyfin Media Player (no GPU)";
        exec = "jellyfinmediaplayer --disable-gpu";
      };

      # "--use-angle=vulkan --use-cmd-decoder=passthrough" prevents flickering
      whatsapp = {
        name = "WhatsApp";
        exec = "${pkgs.chromium}/bin/chromium --use-angle=vulkan --use-cmd-decoder=passthrough --app=\"https://web.whatsapp.com\" --name=WhatsApp";
        icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/48x48/apps/whatsapp.svg";
      };

      navidrome = {
        name = "Navidrome";
        exec = "${pkgs.chromium}/bin/chromium --use-angle=vulkan --use-cmd-decoder=passthrough --app=\"https://navidrome.mattiamari.xyz\" --name=Navidrome";
        # icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/48x48/apps/whatsapp.svg";
      };
    };
  };

  # https://nix.catppuccin.com/options/home-manager-options.html
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "teal";
    waybar.mode = "createLink";
    kvantum.enable = false;
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = true
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "adwaita";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    # https://wiki.hyprland.org/0.40.0/Configuring/Variables
    settings = {
      monitor = [
        "HDMI-A-2,3840x2160@60,auto,1.0,bitdepth,10"
        "Unknown-1,disable"
      ];
      
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

      misc = {
        # force "hyprland logo" wallpaper
        force_default_wallpaper = 0;
      };

      debug = {
        disable_logs = true;
      };

      exec-once = [
        "${pkgs.dunst}/bin/dunst"
        "${pkgs.waybar}/bin/waybar"
      ];

      "$mod" = "SUPER";

      # https://wiki.hyprland.org/0.45.0/Configuring/Dispatchers
      bind = [
        "$mod, Q, exec, alacritty"
        "$mod, E, exec, thunar"
        "$mod, SPACE, exec, rofi -show combi"
        "$mod, W, exec, rofi -show calc -modi calc -no-show-match -no-sort"
        "$mod, C, killactive"
        "$mod, F, fullscreen, 1"
        "$mod, M, exec, rofi -show power-menu -modi power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu"
        ", XF86Calculator, exec, rofi -show calc -modi calc -no-show-match -no-sort"

        # float and pin (i.e. picture in picture that follows you across workspaces)
        "$mod, P, toggleFloating"
        "$mod, P, pin, active"
        #"$mod, P, fakefullscreen"
      
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
        ",code:123, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        ",code:122, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",code:121, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        # media control
        ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
        ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"

        # brightness control
        ",code:233, exec, ddccontrol -r 0x10 -W +5 dev:/dev/i2c-8"
        ",code:232, exec, ddccontrol -r 0x10 -W -5 dev:/dev/i2c-8"
        "$mod, F2, exec, ddccontrol -r 0x10 -w 100 dev:/dev/i2c-8"
        "$mod, F1, exec, ddccontrol -r 0x10 -w 50 dev:/dev/i2c-8"

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

      windowrulev2 = [
        # Smart gaps
        "bordersize 0, floating:0, onworkspace:w[tv1]"
        "rounding 0, floating:0, onworkspace:w[tv1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"

        "tile, title:^web\.whatsapp\.com.*$"
        "float, title:Calculator"
        "float, title:^Extension.*Bitwarden.*$"
      ];

      workspace = [
        # Smart gaps
        "w[tv1], gapsin:0, gapsout:0"
        "f[1], gapsout:0, gapsin:0"
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
    systemd.enable = false;
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
          ignored-sinks = ["Easy Effects Sink"];
          on-click = "${pkgs.pwvucontrol}/bin/pwvucontrol";
        };

        tray = {
          icon-size = 20;
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
      modes = "drun,window,ssh";
      combi-modes = "window,drun,ssh";
      show-icons = true;
      terminal = "alacritty";
      combi-display-format = " <span weight='light'>{mode}</span> {text}";
    };
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "cloud";
    };
  };

  programs.git = {
    enable = true;
    delta.enable = true; # fancy diff
  };

  programs.eza.enable = true;
  programs.fzf.enable = true;
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;

  programs.helix = {
    enable = true;
    
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

  programs.neovim = {
    enable = true;
    package = pkgsUnstable.neovim-unwrapped;
    defaultEditor = true;
    vimAlias = true;
    withPython3 = true;

    plugins = with pkgsUnstable.vimPlugins; [
      LazyVim
    ];

    extraPackages = with pkgs; [
      # lazyvim requirements
      git
      lazygit
      gcc
      gnumake
      curl
      fzf
      ripgrep
      fd

      unzip
      wl-clipboard
      nil # Nix language server
      bacon # Rust code checker
      rust-analyzer
    ];

    extraLuaConfig = ''
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          { import = "lazyvim.plugins.extras.lang.rust" },

          -- import/override with your plugins
          -- { import = "plugins" },

          {
            "nvim-treesitter/nvim-treesitter",
            opts = {
              ensure_installed = {
                "bash",
                "html",
                "css",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "query",
                "regex",
                "vim",
                "yaml",
                "nix",
              },
            },
          },

          {
            "neovim/nvim-lspconfig",
            opts = {
              servers = {
                nil_ls = {
                  mason = false,
                },
                bacon_ls = {
                  mason = false,
                },
              },
            }
          }

        },
        defaults = {
          lazy = false,
          version = false, -- always use the latest git commit
        },
        install = { colorscheme = { "tokyonight", "habamax" } },
        checker = {
          enabled = true, -- check for plugin updates periodically
          notify = false, -- notify on update
        }, -- automatically check for plugin updates
        performance = {
          rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
              "gzip",
              -- "matchit",
              -- "matchparen",
              -- "netrwPlugin",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
    '';
  };

  # Keeping this here for when I'll want to move the nvim config in its own file
  #home.file = {
  #  ".config/nvim" = {
  #    source = ./nvim;
  #    recursive = true;
  #  };
  #};

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
