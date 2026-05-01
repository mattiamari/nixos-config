{ pkgs, ... }:
{

  home.packages = with pkgs; [
    vscode
    opencode
    claude-code

    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
    bacon
    sqlx-cli

    gcc
    gnumake

    nodejs
    pnpm

    watchexec

    sqlite
    sqlitebrowser
  ];

}
