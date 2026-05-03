{ pkgs, config, ... }:
{

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureUsers = [
      {
        name = config.services.mysqlBackup.user;
        ensurePermissions = {
          "*.*" = "SELECT, LOCK TABLES";
        };
      }
    ];
  };

  services.mysqlBackup = {
    enable = true;
    calendar = "*-*-* 01:00";
  };

  services.postgresql = {
    enable = true;
  };

  services.postgresqlBackup = {
    enable = true;
    startAt = "*-*-* 01:00:00";
    compression = "zstd";
    compressionLevel = 10;
  };

}
