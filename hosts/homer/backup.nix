{ ... }:
let
  myConfig = import ./common.nix;
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
          /run/wrappers/bin/mount /dev/disk/by-uuid/d3a10dc7-e09b-4737-a155-9806e26859ee /mnt/backup-a/${name}
        '';

        postHook = ''
          /run/wrappers/bin/umount /mnt/backup-a/${name}
        '';

        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${myConfig.secretsDir}/borg-${name}";
        };

        repo = "/mnt/backup-a/${name}/borg-${name}";
        removableDevice = true;

        readWritePaths = [ "/mnt/backup-a/${name}" ];

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
        ];
      };

      mattia = mkJob {
        name = "mattia";
        startAt = "*-*-* 02:10"; # daily at 2 am

        paths = [
         "/media/storage/mattia"
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
}
