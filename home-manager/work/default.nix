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

    packages = with pkgs; [
      openfortivpn
      #pkgsUnstable.jetbrains.idea-ultimate
      podman-compose
      podman-tui
      dive
    ];

    sessionVariables = {
      COLORTERM = "truecolor";
    };
  };

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 7d";
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
      tree-sitter

      unzip
      wl-clipboard
      nil # Nix language server
      jdt-language-server
    ];

    extraLuaConfig = ''
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          { import = "lazyvim.plugins.extras.lang.java" },

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
                jdtls = {
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
}
