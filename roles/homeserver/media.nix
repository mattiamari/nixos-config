{ pkgs, ... }:
{

  services.jellyfin = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = pkgs.jellyfin;
  };
  reverseProxy.privateServices.jellyfin.port = 8096;

  environment.systemPackages = [
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  services.navidrome = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    settings = {
      Port = 4533;
      MusicFolder = "/media/storage/media/music/main";
    };
  };
  reverseProxy.publicServices.navidrome.port = 4533;

}
