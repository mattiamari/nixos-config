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

  # fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # smart `cd` command
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # better `ls`
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

}
