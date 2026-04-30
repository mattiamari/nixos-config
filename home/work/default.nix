{
  pkgs,
  pkgsMaven,
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
    username = "work";
    homeDirectory = "/home/work";

    stateVersion = "24.05";

    packages = with pkgs; [
      openfortivpn
      (jetbrains.idea.override { vmopts = "-Xmx8192m"; })
      podman-tui
      dive
      maven
      corretto17
      nodejs_20
      pnpm
      watchexec
      awscli2
      spotify
      ungoogled-chromium
      libxml2 # for xmllint
      claude-code
    ];

    sessionVariables = {
      # JAVA_8_HOME = pkgs.jdk8.home;
      JAVA_17_HOME = pkgs.corretto17.home;
      JAVA_HOME = pkgs.corretto17.home;
      # MAVEN_36_HOME = "${pkgsMaven.maven}/maven";
      MAVEN_HOME = "${pkgs.maven}/maven";
      # CATALINA_8_HOME = pkgsMaven.tomcat8;
      CATALINA_9_HOME = pkgs.tomcat9;
      CATALINA_BASE = "/home/work/vivaticket/catalina-base";
      CATALINA_TMPDIR = "/tmp";
    };
  };

}
