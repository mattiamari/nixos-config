{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old";
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

  services.xserver.layout = "it";
  console.keyMap = "it";

  environment.systemPackages = with pkgs; [
    wget
    git
    btop
    htop
    smartmontools
    gdu
    tree
    zip
    helix
    nil # Nix language server
  ];

  programs.zsh.enable = true;
  programs.tmux = {
    enable = true;
  };

  environment.shellAliases = {
    ll = "ls -lah";
    ".." = "cd ..";
  };
}
