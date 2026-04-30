{ config, ... }:
{

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    oh-my-zsh = {
      enable = true;
      theme = "cloud";
    };
  };

  home.sessionVariables.COLORTERM = "truecolor";

  programs.fzf.enable = true; # fuzzy finder
  programs.zoxide.enable = true; # smart `cd` command

}
