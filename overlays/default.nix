{ pkgsStable, pkgs2411 }:

final: prev: {
  torzu = pkgs2411.torzu;

  photoprism = pkgsStable.photoprism;
  calibre-web = pkgsStable.calibre-web;
  awscli2 = pkgsStable.awscli2;
  weston = pkgsStable.weston;
}
