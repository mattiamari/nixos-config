{ pkgs, lib, ... }:
{

  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./rofi.nix
  ];

  options.desktop.terminal = lib.mkOption {
    type = lib.types.str;
    default = "${pkgs.ghostty}/bin/ghostty";
    description = "Default terminal emulator path";
  };

  config = {
    xdg.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
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

    # new default since nixos 26.05
    gtk.gtk4.theme = null;

    qt = {
      enable = true;
      style.name = "adwaita-dark";
      platformTheme.name = "adwaita";
    };

    services.easyeffects.enable = true;

    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # mouse-scroll-multiplier = "precision:1,discrete:3";
      };
    };
  };

}
