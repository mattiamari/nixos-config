{ config, lib, pkgs, ... }:
with lib;
let
  myConfig = import ./common.nix;
  partA = "7a251ca0-e687-4806-ab32-745239051fe3";
  diskA = "ata-WDC_WD20EZRX-00DC0B0_WD-WCC1T0831876";
  partB = "70afe25f-2ed5-4d41-a4dc-e4bd10052416";
  diskB = "ata-WDC_WD30EZRZ-00Z5HB0_WD-WCC4N3RT31NE";

  backupAJobs = {
    system = {
      startAt = "*-*-* 02:00"; # daily at 2 am
    
      paths = [
        "/home"
        "/var/lib"
        "/var/backup"
        "/media/storage/syncthing"
      ];

      exclude = [
        "*/cache"
        "*/.cache"
        "/var/lib/jellyfin/transcodes"
        "/var/lib/mysql" # already backed-up by mysqlbackup in /var/backup
        "/var/lib/postgresql" # already backed-up by postgresqlBackup in /var/backup
        "*/.local/share/containers/storage/overlay"
      ];
    };

    mattia = {
      startAt = "*-*-* 02:10"; # daily at 2 am

      paths = [
       "/media/storage/mattia"
       "/media/storage/media/music/main"
      ];

      exclude = [];
    };

    family = {
      startAt = "*-*-* 02:20"; # daily at 2 am

      paths = [
       "/media/storage/famiglia"
      ];

      exclude = [];
    };
  };
in
{
  #
  # Backup A
  #

  services.borgbackup.jobs = mapAttrs (name: opts: {
    startAt = opts.startAt;
    paths = opts.paths;
    exclude = opts.exclude;
    persistentTimer = true;

    postHook = ''
      df -h /dev/disk/by-uuid/${partA}
      ${pkgs.smartmontools}/bin/smartctl -iA /dev/disk/by-id/${diskA}
    '';

    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${myConfig.secretsDir}/borg-${name}";
    };

    repo = "/mnt/backupa/${name}/borg-${name}";
    removableDevice = true;
    readWritePaths = [ "/mnt/backupa/${name}" ];
    extraCreateArgs = "--stats";

    prune.keep = {
      within = "1d"; # keep everything from last day
      daily = 14;
      weekly = 8;
      monthly = 12;
    };
  }) backupAJobs;

  systemd.mounts = mapAttrsToList (name: opts: {
    what = "/dev/disk/by-uuid/${partA}";
    where = "/mnt/backupa/${name}";
    type = "ext4";
    options = "noauto,nofail";
    mountConfig = {
      DirectoryMode = "0700";
    };
  }) backupAJobs ++ [
    {
      what = "/dev/disk/by-uuid/${partB}";
      where = "/mnt/backupb/everything";
      type = "ext4";
      options = "noauto,nofail";
      mountConfig = {
        DirectoryMode = "0700";
      };
    }
  ];

  # mapAttrs' is like mapAttrs but allows the name to be changed as well.
  # See: https://github.com/NixOS/nixpkgs/blob/23.11/lib/attrsets.nix#L506
  systemd.services = mapAttrs' (name: opts: nameValuePair "borgbackup-job-${name}" {
    wants = [ "mnt-backupa-${name}.mount" ];
    after = [ "mnt-backupa-${name}.mount" ];

    # Unmount disk after backup
    unitConfig.PropagatesStopTo = "mnt-backupa-${name}.mount";
  }) backupAJobs // {
    restic-backups-everything = {
      # Set to 'false' to prevent automatic backup from starting when connecting the external disk
      enable = true;
    
      wants = [ "mnt-backupb-everything.mount" ];
      after = [ "mnt-backupb-everything.mount" ];

      unitConfig.PropagatesStopTo = "mnt-backupb-everything.mount";
    };
  };

  #
  # Backup B (removable)
  #

  # Auto-start backup when external disk is connected
  services.udev = {
    enable = true;
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="block", ENV{DEVLINKS}=="*/dev/disk/by-uuid/${partB}*", ENV{SYSTEMD_WANTS}="restic-backups-everything.service"
    '';
  };
  
  # Needed for 'udisksctl power-off'
  services.udisks2.enable = true;

  services.restic.backups.everything = let b = config.services.borgbackup.jobs; in {
    repository = "/mnt/backupb/everything/restic-everything";
    passwordFile = "${myConfig.secretsDir}/restic-everything";
    timerConfig = null;
    progressFps = 0.1;

    paths = b.system.paths ++ b.mattia.paths ++ b.family.paths;
    exclude = b.system.exclude ++ b.mattia.exclude;

    backupCleanupCommand = ''
      sleep 2
      df -h /dev/disk/by-uuid/${partB}
      ${pkgs.smartmontools}/bin/smartctl -iA /dev/disk/by-id/${diskB}
      sleep 2
      ${pkgs.udisks}/bin/udisksctl power-off -b /dev/disk/by-id/${diskB}
    '';

    pruneOpts = [
      "--keep-daily 15"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 4"
    ];
  };
}
