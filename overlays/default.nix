{ pkgsStable, pkgs2411, ... }:

final: prev: {
  torzu = pkgs2411.torzu;

  photoprism = pkgsStable.photoprism;
  calibre-web = pkgsStable.calibre-web;
  weston = pkgsStable.weston;

  awscli2 = pkgsStable.awscli2;
  maven36 = final.callPackage ../packages/maven36 { jdk = final.jdk8; };
  tomcat8 = final.callPackage ../packages/tomcat8 { };
}
