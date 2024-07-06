switch:
    nixos-rebuild switch --flake . --use-remote-sudo

boot:
    nixos-rebuild boot --flake . --use-remote-sudo

build:
    nixos-rebuild build --flake .

update:
    nix flake update

history:
    nix profile history --profile /nix/var/nix/profiles/system

repl:
    nix repl -f flake:nixpkgs

gc:
    sudo nix-collect-garbage --delete-older-than 7d
