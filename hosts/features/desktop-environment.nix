{ pkgs, ... }:
{

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
  };

  programs.uwsm.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
    ];
  };

  programs.dconf.enable = true;

  services.gvfs.enable = true; # for automount, trash, etc.
  services.udisks2.enable = true;
  services.tumbler.enable = true; # fot thumnbnails

  environment.systemPackages = with pkgs; [
    pwvucontrol
    easyeffects
    alacritty
    ffmpegthumbnailer
    loupe # image viewer
    gnome-calculator
    kdePackages.ark
    firefox
    mpv
  ];

  # list installed fonts: `fc-list -v`
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.noto
  ];

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "teal";
    sddm.enable = true;
  };

  # Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  programs.seahorse.enable = true;

  environment.sessionVariables = {
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

}
