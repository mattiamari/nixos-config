{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    shadow # for rootless podman
    podman-compose
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";
}
