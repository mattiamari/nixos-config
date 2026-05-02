{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    wget
    rsync
    curl
    git
    btop
    htop
    smartmontools
    gdu
    p7zip
    file
    just
    parallel
    ripgrep # 'grep' alternative
    fzf # fuzzy finder
    eza # 'ls' alternative
    fd # 'find' alternative
    yazi # terminal file manager
    ghostty.terminfo # ghostty support for hosts without ghostty installed (e.g. via SSH)
  ];

  programs.zsh.enable = true;
  programs.bat.enable = true;

  programs.tmux = {
    enable = true;

    # Recommended by neovim
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
    withPython3 = false;
    withRuby = false;
  };

  environment.shellAliases = {
    ls = "eza";
    l = "eza -lah";
    ll = "eza -l";
    lt = "eza --tree";
  };
}
