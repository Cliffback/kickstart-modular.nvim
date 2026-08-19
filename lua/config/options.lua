-- [[ Setting options ]]
-- See `:help vim.o`
-- Plugin configuration lives in lua/plugins/*.lua, not here.

local detect = require 'utils.detect-os'

-- Disable netrw (nvim-tree replaces it). Must happen before plugins load.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Line wrapping
vim.opt.linebreak = true
vim.opt.breakat = ' \t,-'
vim.o.breakindent = true

-- Search
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
-- On WSL this is handled by the clip.exe autocmd in config/autocmds.lua.
if not detect.IS_WSL then
  vim.o.clipboard = 'unnamedplus'
end

vim.o.undofile = true

vim.o.signcolumn = 'yes'
vim.o.showmode = false

vim.o.updatetime = 250
-- NOTE: kickstart set this to 300 to make which-key feel responsive. which-key
-- v3 has its own `delay`, so the only thing 300ms still affects is multi-key
-- mappings like <Esc><Esc> in terminal mode, where it is needlessly tight.
vim.o.timeoutlen = 500

vim.o.completeopt = 'menuone,noselect'

vim.o.termguicolors = true

-- [[ Diagnostics ]]
-- virtual_lines renders the message under the offending line rather than
-- trailing off the right edge; limiting it to the current line keeps the
-- buffer from jumping around.
vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = { current_line = true },
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
      [vim.diagnostic.severity.HINT] = ' ',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
