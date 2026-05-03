{ ... }:
{

  imports = [
    ../../modules/radarr-ita.nix
    ../../modules/sonarr-ita.nix
  ];

  services.qbittorrent = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    profileDir = "/var/lib/qbittorrent";
    webuiPort = 8100;
  };
  reverseProxy.privateServices.qbittorrent.port = 8100;

  services.radarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
  };
  reverseProxy.privateServices.radarr.port = 7878;

  services.radarrIta = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 7879;
  };
  reverseProxy.privateServices.radarr-ita.port = 7879;

  services.sonarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
  };
  reverseProxy.privateServices.sonarr.port = 8989;

  services.sonarrIta = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 8990;
  };
  reverseProxy.privateServices.sonarr-ita.port = 8990;

  services.prowlarr = {
    enable = true;
  };
  reverseProxy.privateServices.prowlarr.port = 9696;

  services.flaresolverr.enable = true;

  services.lidarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
  };
  reverseProxy.privateServices.lidarr.port = 8686;

  services.bazarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
  };
  reverseProxy.privateServices.bazarr.port = 6767;

}
