{ config, lib, ... }:
{
  imports = [
    ../../features/podman.nix
    ../../features/reverse-proxy.nix

    # basics
    ./users.nix
    ./databases.nix
    ./monitoring.nix
    ./networking.nix

    # services
    ./smb.nix
    ./filebrowser.nix
    ./media.nix
    ./arr.nix
    ./services-misc.nix
  ];

  options.homeserver = {
    adminUser = lib.mkOption {
      type = lib.types.str;
      default = "admin";
    };
    secretsDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.homeserver.adminUser}/secrets";
    };
    localIP = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    networking = {
      nftables.enable = true;

      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
          53
          80
          443
          853
        ];
        allowedUDPPorts = [
          53
          443
          853
        ];
      };
    };

    reverseProxy = {
      enable = true;
      environmentFilePath = "${config.homeserver.secretsDir}/caddy";
    };

  };
}
