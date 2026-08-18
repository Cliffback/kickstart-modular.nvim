-- Neovim configuration
--
--   lua/config/    editor settings, keymaps, autocmds, LSP servers
--   lua/plugins/   one file per area; lazy.nvim imports the whole directory
--   lua/utils/     shared helpers
--
-- Plugin configuration belongs in lua/plugins/*.lua next to its spec, not in
-- config/, so that lazy-loading actually works. A `require()` at startup in
-- config/ defeats any `keys`/`cmd`/`ft` trigger on the plugin it loads.

-- Set <space> as the leader key.
-- NOTE: must happen before plugins load, or they capture the wrong leader.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install lazy.nvim ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

require('lazy').setup {
  spec = { { import = 'plugins' } },
  install = { colorscheme = { 'catppuccin' } },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        'netrwPlugin',
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
