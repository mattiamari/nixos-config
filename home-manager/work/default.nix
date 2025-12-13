{
  config,
  pkgs,
  lib,
  pkgsMaven,
  catppuccin,
  ...
}:
{
  imports = [
    catppuccin.homeModules.catppuccin
  ];

  programs.home-manager.enable = true;

  home = {
    username = "work";
    homeDirectory = "/home/work";

    stateVersion = "24.05";

    packages = with pkgs; [
      openfortivpn
      (jetbrains.idea-ultimate.override { vmopts = "-Xmx8192m"; })
      podman-compose
      podman-tui
      dive
      maven
      corretto17
      nodejs_20
      pnpm
      watchexec
      awscli2
      spotify
      ungoogled-chromium
      libxml2 # for xmllint
    ];

    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    sessionVariables = {
      COLORTERM = "truecolor";
      JAVA_8_HOME = pkgs.jdk8.home;
      JAVA_17_HOME = pkgs.corretto17.home;
      JAVA_HOME = pkgs.corretto17.home;
      MAVEN_36_HOME = "${pkgsMaven.maven}/maven";
      MAVEN_HOME = "${pkgs.maven}/maven";
      CATALINA_8_HOME = pkgsMaven.tomcat8;
      CATALINA_9_HOME = pkgs.tomcat9;
      CATALINA_BASE = "/home/work/vivaticket/catalina-base";
      CATALINA_TMPDIR = "/tmp";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # https://nix.catppuccin.com/options/home-manager-options.html
  catppuccin = {
    enable = false;
    flavor = "macchiato";
    accent = "teal";
    waybar.mode = "createLink";
    kvantum.enable = false;
    rofi.enable = false;
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
    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    # };

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
        kb_layout = "us";
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
      ++ builtins.genList (n: "$mod, ${toString (n + 1)}, workspace, ${toString (n + 1)}") 9

      # move windows between workspaces
      ++ builtins.genList (n: "$mod SHIFT, ${toString (n + 1)}, movetoworkspace, ${toString (n + 1)}") 9;

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

        "noinitialfocus, class:(jetbrains-idea), title:^win.*"
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
    in
    {
      enable = false;
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
    style = ../mattia/waybar.css;

    # https://github.com/Alexays/Waybar/wiki/Configuration
    settings = {
      main = {
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "clock"
          "tray"
        ];

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
            default = [
              ""
              ""
            ];
          };
          ignored-sinks = [ "Easy Effects Sink" ];
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
    package = pkgs.rofi;

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
  };

  # fancy diff
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.eza.enable = true; # `ls` alternative
  programs.fzf.enable = true; # fuzzy finder
  programs.fd.enable = true; # `find` alternative
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true; # smart `cd` command
  programs.bat.enable = true; # nicer `cat`
  programs.lazygit.enable = true;

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
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      friendly-snippets
      lualine-nvim
      luasnip
      mini-completion
      mini-snippets
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      telescope-nvim
      vim-fugitive
    ];

    extraPackages = with pkgs; [
      git
      fzf
      ripgrep
      powerline-fonts
      wl-clipboard

    ];

    extraLuaConfig = ''
      -- Misc
      vim.o.number = true
      vim.o.relativenumber = true
      vim.o.wrap = false

      -- Indents
      vim.o.tabstop = 4
      vim.o.shiftwidth = 4
      vim.o.softtabstop = 4
      vim.o.expandtab = true
      vim.o.smartindent = true
      vim.o.autoindent = true

      -- Search
      vim.o.ignorecase = true
      vim.o.smartcase = true
      vim.o.incsearch = true

      -- Appearance
      vim.o.termguicolors = true -- enable 24-bit colors
      vim.o.winborder = "rounded"
      vim.o.clipboard = "unnamedplus"
      vim.o.colorcolumn = "100"
      vim.o.cursorline = true
      vim.o.showmatch = true -- highlight matching brackets

      -- Files
      vim.o.swapfile = false
      vim.o.undofile = true
      vim.o.undodir = vim.fn.expand("~/.nvim/undo")

      -- Behaviour
      vim.o.backspace = "indent,eol,start"


      --
      -- KEYMAP
      --
      vim.g.mapleader = ' '

      vim.keymap.set('n', '<leader>q', ':quit<CR>')
      vim.keymap.set('n', '<leader>f', ':Telescope find_files<CR>')
      vim.keymap.set('n', '<leader>/', ':Telescope live_grep<CR>')
      vim.keymap.set('n', '<leader>b', ':Telescope buffers<CR>')
      vim.keymap.set('n', '<leader>cr', ':Telescope lsp_references<CR>')
      vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
      vim.keymap.set('i', '<c-space>', '<c-x><c-o>', { noremap = true, silent = true })

      vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
      vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })

      vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
      vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })

      vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
      vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
      vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
      vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

      vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
      vim.keymap.set("v", "<A-k>", ":m '>-2<CR>gv=gv", { desc = "Move selected lines up" })

      vim.keymap.set("v", "<", "<gv", { desc = "Indent right, keep selection" })
      vim.keymap.set("v", ">", ">gv", { desc = "Indent left, keep selection" })


      --
      -- LSP
      --
      vim.lsp.enable({ })

      require("mini.completion").setup()

      local gen_loader = require('mini.snippets').gen_loader
      require("mini.snippets").setup({
          snippets = { gen_loader.from_lang() }
      })

      -- Auto-select first completion option but don't insert
      vim.opt.completeopt = { "menu", "menuone", "noinsert", "popup" }

      vim.lsp.config("jinja_lsp", {
          filetypes = {"htmldjango"}
      })


      --
      -- PLUGINS
      --
      require("lualine").setup({
          sections = {
              lualine_c = {{"filename", path=2}},
          },
      })

      require("nvim-treesitter.configs").setup({
          highlight = { enable = true }
      })

    '';
  };
}
