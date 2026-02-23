-- Misc
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false

-- Indents
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true

-- Appearance
vim.o.termguicolors = true -- enable 24-bit colors
vim.o.winborder = "rounded"
vim.o.clipboard = "unnamedplus"
vim.o.colorcolumn = "100"
vim.o.cursorline = true
vim.o.showmatch = true -- highlight matching brackets

-- Files
vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = vim.fn.expand("~/.nvim/undo")

-- Behaviour
vim.o.backspace = "indent,eol,start"


--
-- KEYMAP
--
vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>q', ':bd<CR>')
vim.keymap.set('n', '<leader>w', ':w<CR>')
vim.keymap.set('n', '<leader><C-l>', ':nohlsearch<CR>')
vim.keymap.set('n', '<leader>f', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>/', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>cr', ':Telescope lsp_references<CR>')
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>di', function()
    vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
end, { desc = "Toggle inline diagnostics" })
vim.keymap.set('i', '<A-space>', '<c-x><c-o>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>bb', ':Telescope buffers<CR>', { desc = "List buffers" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<Tab>", ":b#<CR>", { desc = "Cycle last buffers" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "<A-k>", ":m '>-2<CR>gv=gv", { desc = "Move selected lines up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left, keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right, keep selection" })

vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end,
    { desc = "Ask opencode" })
vim.keymap.set({ "n", "x" }, "<leader>ox", function() require("opencode").select() end,
    { desc = "Execute opencode action…" })
vim.keymap.set({ "n", "x" }, "ga", function() require("opencode").prompt("@this") end, { desc = "Add to opencode" })
vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
    { desc = "opencode half page up" })
vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
    { desc = "opencode half page down" })

--
-- LSP
--
vim.lsp.enable({ "lua_ls", "nil_ls", "rust_analyzer", "jinja_lsp" })

vim.lsp.config("jinja_lsp", {
    filetypes = { "htmldjango" }
})

require("mini.completion").setup()

-- local gen_loader = require('mini.snippets').gen_loader
-- require("mini.snippets").setup({
--     snippets = { gen_loader.from_lang() }
-- })

-- Auto-select first completion option but don't insert
vim.opt.completeopt = { "menu", "menuone", "noinsert", "popup" }

--
-- PLUGINS
--
require("lualine").setup({
    sections = {
        lualine_c = { { "filename", path = 2 } },
    },
})

require("nvim-treesitter").setup({
    highlight = { enable = true }
})

require("nvim-autopairs").setup()

require("conform").setup({
    formatters_by_ft = {
        htmldjango = { "djlint", lsp_format = "fallback" },
        -- html = { "tidy -quiet -indent -", lsp_format = "fallback" },
        rust = { "rustfmt", lsp_format = "fallback" },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
    },
})

--
-- FILETYPES
--
vim.filetype.add({
    extension = { jinja = "htmldjango" }
})
