{
  pkgs,
  lib,
  catppuccin,
  ...
}:
{
  imports = [
    ../features/gc.nix
    ../features/desktop-environment
    ../features/neovim
    ../features/git.nix
    ../features/zsh.nix
    catppuccin.homeModules.catppuccin
  ];

  programs.home-manager.enable = true;

  home = {
    username = "mattia";
    homeDirectory = "/home/mattia";

    stateVersion = "23.11";

    packages = with pkgs; [
      vlc
      supersonic-wayland
      obsidian
      # calibre
      #jellyfin-media-player
      gimp
      xournalpp
      kdePackages.okular
      libreoffice-fresh
      spotify
      sshfs
      telegram-desktop
      ungoogled-chromium
      # (callPackage ../../packages/zen-browser.nix {})
      sqlite
      sqlitebrowser
      torzu
      prismlauncher
      vscode
      opencode
      claude-code

      rustc
      cargo
      rustfmt
      rust-analyzer
      clippy
      bacon
      sqlx-cli

      gcc
      gnumake
      nodejs
      pnpm
      watchexec
    ];
  };

  xdg.desktopEntries = {
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

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  # Fix "the system tray is not currently available" message from syncthing tray
  systemd.user.services.syncthingtray.Service.ExecStartPre =
    lib.mkForce "${pkgs.coreutils}/bin/sleep 3";
  systemd.user.services.syncthingtray.Service.ExecStart =
    lib.mkForce "${pkgs.syncthingtray}/bin/syncthingtray --wait";
  systemd.user.services.syncthingtray.Unit.After = lib.mkForce "waybar.service";

  services.easyeffects.enable = true;
}
