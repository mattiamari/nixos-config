{
  pkgsStable,
  pkgs2411,
  pkgsMaven,
  ...
}:

final: prev: {
  torzu = pkgs2411.torzu;

  photoprism = pkgsStable.photoprism;
  calibre-web = pkgsStable.calibre-web;
  weston = pkgsStable.weston;

  awscli2 = pkgsStable.awscli2;
  maven36 = pkgsMaven.maven;
  tomcat8 = pkgsMaven.tomcat8;
}
