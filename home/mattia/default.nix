{
  pkgs,
  catppuccin,
  ...
}:
{
  imports = [
    ../features/gc.nix
    ../features/desktop-environment
    ../features/syncthing-with-tray.nix
    ../features/neovim
    ../features/git.nix
    ../features/zsh.nix
    ../features/development.nix
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
      torzu
      prismlauncher
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
}
