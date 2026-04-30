{ pkgs, ... }:
{

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    withPython3 = false;
    withRuby = false;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      friendly-snippets
      lualine-nvim
      luasnip
      mini-completion
      mini-snippets
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      plenary-nvim # needed by telescope
      telescope-nvim
      vim-fugitive
      nvim-autopairs
      conform-nvim
    ];

    extraPackages = with pkgs; [
      git
      fzf
      ripgrep
      fd # faster 'find'
      powerline-fonts
      wl-clipboard
      tree-sitter

      # language servers
      lua-language-server
      nil # Nix language server
      rust-analyzer
      jinja-lsp
      html-tidy
      djlint
    ];

    initLua = builtins.readFile ./nvim.lua;
  };

}
