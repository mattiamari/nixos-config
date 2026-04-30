{ ... }:
{

  programs.git = {
    enable = true;
    signing.format = "openpgp";
  };

  # fancy diff
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.lazygit.enable = true;

}
