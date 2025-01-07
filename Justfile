switch:
    nixos-rebuild switch --flake . --use-remote-sudo

boot:
    nixos-rebuild boot --flake . --use-remote-sudo

build:
    nixos-rebuild build --flake .

homer-boot:
    nixos-rebuild boot --flake .#homer --target-host mattia@homer --build-host mattia@homer --use-remote-sudo

homer-switch:
    nixos-rebuild switch --flake .#homer --target-host mattia@homer --build-host mattia@homer --use-remote-sudo

update:
    nix flake update

history:
    nix profile history --profile /nix/var/nix/profiles/system

repl:
    nix repl -f flake:nixpkgs

gc:
    sudo nix-collect-garbage --delete-older-than 7d

gc-user:
    nix-collect-garbage --delete-older-than 7d
