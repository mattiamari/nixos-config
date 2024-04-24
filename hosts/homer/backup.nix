{ config, pkgs, ... }:
let
  myConfig = import ./common.nix;
  externalDiskUUID = "70afe25f-2ed5-4d41-a4dc-e4bd10052416";
  externalDiskID = "ata-WDC_WD30EZRZ-00Z5HB0_WD-WCC4N3RT31NE";
in
{
  services.borgbackup.jobs =
    let
      mkJob = { name, startAt, paths, exclude ? [] }: {
        inherit startAt;
        inherit paths;
        inherit exclude;
        persistentTimer = true;

        preHook = ''
          mkdir -p /mnt/backup-a/${name}
          /run/wrappers/bin/mount /dev/disk/by-uuid/7a251ca0-e687-4806-ab32-745239051fe3 /mnt/backup-a/${name}
        '';

        postHook = ''
          ${pkgs.smartmontools}/bin/smartctl -iA /dev/disk/by-id/ata-WDC_WD20EZRX-00DC0B0_WD-WCC1T0831876
          /run/wrappers/bin/umount /mnt/backup-a/${name}
        '';

        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${myConfig.secretsDir}/borg-${name}";
        };

        repo = "/mnt/backup-a/${name}/borg-${name}";
        removableDevice = true;
        readWritePaths = [ "/mnt/backup-a/${name}" ];
        extraCreateArgs = "--stats";

        prune.keep = {
          within = "1d"; # keep everything from last day
          daily = 14;
          weekly = 8;
          monthly = 12;
        };
      };
    in
    {
      system = mkJob {
        name = "system";
        startAt = "*-*-* 02:00"; # daily at 2 am
      
        paths = [
          "/home"
          "/var/lib"
        ];

        exclude = [
          "*/cache"
          "*/.cache"
          "/var/lib/jellyfin/transcodes"
          "*/.local/share/containers/storage/overlay"
        ];
      };

      mattia = mkJob {
        name = "mattia";
        startAt = "*-*-* 02:10"; # daily at 2 am

        paths = [
         "/media/storage/mattia"
        ];

        exclude = [
          "/media/storage/mattia/Software"
          "/media/storage/mattia/things"
        ];
      };

      family = mkJob {
        name = "family";
        startAt = "*-*-* 02:20"; # daily at 2 am

        paths = [
         "/media/storage/famiglia"
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /mnt/backup-a/system 0700 root root"
      "d /mnt/backup-a/mattia 0700 root root"
      "d /mnt/backup-a/family 0700 root root"
    ];

    # Auto-start backup when external disk is connected
    services.udev = {
      enable = true;
      extraRules = ''
        ACTION=="add", SUBSYSTEM=="block", ENV{DEVLINKS}=="*/dev/disk/by-uuid/${externalDiskUUID}*", ENV{SYSTEMD_WANTS}="restic-backups-everything.service"
      '';
    };
    
    # Needed for 'udisksctl power-off'
    services.udisks2.enable = true;

    services.restic.backups.everything = let b = config.services.borgbackup.jobs; in {
      repository = "/mnt/backupb/everything/restic-everything";
      passwordFile = "${myConfig.secretsDir}/restic-everything";
      timerConfig = null;

      paths = b.system.paths ++ b.mattia.paths ++ b.family.paths ++ [
        "/media/storage/syncthing"
      ];
      exclude = b.system.exclude ++ b.mattia.exclude;

      backupCleanupCommand = ''
        sleep 2
        ${pkgs.smartmontools}/bin/smartctl -iA /dev/disk/by-id/${externalDiskID}
        ${pkgs.udisks}/bin/udisksctl power-off -b /dev/disk/by-id/${externalDiskID}
      '';

      pruneOpts = [
        "--keep-daily 15"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 4"
      ];
    };

    # Auto-mount and unmount external disk
    systemd.services.restic-backups-everything = {
      wants = [ "mnt-backupb-everything.mount" ];
      after = [ "mnt-backupb-everything.mount" ];

      unitConfig = {
        PropagatesStopTo = "mnt-backupb-everything.mount";
      };
    };

    systemd.mounts = [
      {
        what = "/dev/disk/by-uuid/${externalDiskUUID}";
        where = "/mnt/backupb/everything";
        type = "ext4";
        options = "noauto,nofail";
        mountConfig = {
          DirectoryMode = "0700";
        };
      }
    ];
}
