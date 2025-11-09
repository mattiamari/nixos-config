switch:
    nixos-rebuild switch --flake . --ask-sudo-password --show-trace

boot:
    nixos-rebuild boot --flake . --ask-sudo-password --show-trace

build:
    nixos-rebuild build --flake . --show-trace

homer-test:
    nixos-rebuild test --flake .#homer --target-host mattia@homer --ask-sudo-password

homer-boot:
    nixos-rebuild boot --flake .#homer --target-host mattia@homer --ask-sudo-password --show-trace

homer-switch:
    nixos-rebuild switch --flake .#homer --target-host mattia@homer --ask-sudo-password --show-trace

wsl-build-image:
  sudo nix run .#nixosConfigurations.wsl.config.system.build.tarballBuilder

update:
    nix flake update

list-generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

repl:
    nix repl -f flake:nixpkgs

gc:
    sudo nix-collect-garbage --delete-older-than 7d

gc-user:
    nix-collect-garbage --delete-older-than 7d
