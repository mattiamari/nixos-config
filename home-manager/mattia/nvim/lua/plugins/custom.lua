return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "rust", "ron", "htmldjango" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jinja_lsp = {
          filetypes = { "jinja", "html" },
        },
      },
    },
  },
}
