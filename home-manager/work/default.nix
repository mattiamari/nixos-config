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

    packages =
    let
      idea = pkgsUnstable.jetbrains.idea-ultimate.override { vmopts = "-Xmx8G"; };
    in
    with pkgs; [
      openfortivpn
      idea
      podman-compose
      podman-tui
      dive
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
    defaultEditor = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      gcc
      gnumake
      unzip
      fd
      wl-clipboard
      #python3 # for jdtls
    ];
  };

  home.file = {
    ".config/nvim" = {
      source = ../mattia/nvim;
      recursive = true;
    };

    ".config/nvim/lua/plugins/jdtls.lua" = {
      text = ''
        return {
          {
            "mfussenegger/nvim-jdtls",
            opts = function()
              local mason_registry = require("mason-registry")
              local lombok_jar = mason_registry.get_package("jdtls"):get_install_path() .. "/lombok.jar"
              return {
                -- How to find the root dir for a given filename. The default comes from
                -- lspconfig which provides a function specifically for java projects.
                root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir,

                -- How to find the project name for a given root dir.
                project_name = function(root_dir)
                  return root_dir and vim.fs.basename(root_dir)
                end,

                -- Where are the config and workspace dirs for a project?
                jdtls_config_dir = function(project_name)
                  return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
                end,
                jdtls_workspace_dir = function(project_name)
                  return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
                end,

                -- How to run jdtls. This can be overridden to a full java command-line
                -- if the Python wrapper script doesn't suffice.
                cmd = {
                  "${pkgs.python3}/bin/python",
                  "${pkgs.jdt-language-server}/bin/jdtls",
                  string.format("--jvm-arg=-javaagent:%s", lombok_jar),
                },
                full_cmd = function(opts)
                  local fname = vim.api.nvim_buf_get_name(0)
                  local root_dir = opts.root_dir(fname)
                  local project_name = opts.project_name(root_dir)
                  local cmd = vim.deepcopy(opts.cmd)
                  if project_name then
                    vim.list_extend(cmd, {
                      "-configuration",
                      opts.jdtls_config_dir(project_name),
                      "-data",
                      opts.jdtls_workspace_dir(project_name),
                    })
                  end
                  return cmd
                end,

                -- These depend on nvim-dap, but can additionally be disabled by setting false here.
                dap = { hotcodereplace = "auto", config_overrides = {} },
                dap_main = {},
                test = true,
                settings = {
                  java = {
                    inlayHints = {
                      parameterNames = {
                        enabled = "all",
                      },
                    },
                  },
                },
              }
            end
          },
        }
      '';
      };
  };
}
