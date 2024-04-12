# My WIP NixOS config

## Generating ISO image for RescUSB
```bash
nix build .#nixosConfigurations.rescusb.config.system.build.isoImage
```
