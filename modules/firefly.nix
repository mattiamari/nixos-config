{config, pkgs, lib, ...}:

with lib;
{
  systemd.services.firefly = 
    let
      serviceName = "firefly";
      podman = "${config.virtualisation.podman.package}/bin/podman";
      cleanup = [
        "${podman} stop --ignore ${serviceName}"
        "${podman} rm --ignore --force ${serviceName}"
      ];
    in
    {
      enable = true;
      wantedBy = ["default.target"];
      after = ["network.target"];
      description = "Firefly III container";
      serviceConfig = {
        User = serviceName;
        WorkingDirectory = "/home/${serviceName}";
        ExecStartPre = cleanup;
        ExecStart = concatStringsSep " " ([
          "${podman} run"
          "--rm"
          "--name=${serviceName}"
          "--sdnotify=conmon"
          "--log-driver=journald"
          "-p 127.0.0.1:8097:8080"
          "-v firefly_uploads:/var/www/html/storage/upload"
          "-e APP_KEY=xnMHkPV5Z2tAF8k5oSpkzGGneGeH79Qm"
          "-e DB_HOST=host.containers.internal"
          "-e DB_PORT=3306"
          "-e DB_CONNECTION=mysql"
          "-e DB_DATABASE=firefly"
          "-e DB_USERNAME=firefly"
          "-e DB_PASSWORD=firefly"
          "fireflyiii/core:version-6.1"
        ]);
        ExecStop = cleanup;
      };
    };

  # Note: DB user must be allowed with query `grant all privileges on firefly.* to 'firefly'@'%' identified by 'firefly'`

  users.groups.firefly = {};

  users.users.firefly = {
    isNormalUser = true;
    linger = true;
    createHome = true;
    group = "firefly";
  };
}
