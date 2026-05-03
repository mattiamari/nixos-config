{ config, pkgs, ... }:
{

  services.ddclient = {
    enable = true;
    usev4 = "cmd, cmd='${pkgs.curl}/bin/curl -fs https://ipv4.icanhazip.com'"; # https://github.com/ddclient/ddclient/issues/635#issuecomment-2098950409
    protocol = "cloudflare";
    username = "token";
    passwordFile = "${config.homeserver.secretsDir}/ddclient-cloudflare-key";
    zone = config.reverseProxy.publicDomain;
    domains = [
      config.reverseProxy.publicDomain
      "*.${config.reverseProxy.publicDomain}"
    ];
    verbose = true;
  };

  services.adguardhome = {
    enable = true;
    mutableSettings = true;

    # https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file
    settings = {
      http = {
        address = "127.0.0.1:3000";
      };
      dns = {
        # prevents conflicts with Podman's aardvark
        bind_hosts = [ config.homeserver.localIP ];
      };
      # Commenting this so that I can change password in the config file
      # users = [
      #   {
      #     name = config.homeserver.adminUser;
      #     password = "$2y$10$b2Sozdie36mtEFA3JDpX3eH9rd3tu6hixFkxu5Pd70h9.zxsFxp9i"; # "changeme"
      #   }
      # ];
      filtering = {
        rewrites = [
          {
            domain = "*.${config.reverseProxy.publicDomain}";
            answer = config.homeserver.localIP;
            enabled = true;
          }
        ];
      };
    };
  };

  reverseProxy.privateServices.adguard.port = 3000;

}
