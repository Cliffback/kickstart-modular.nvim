-- [[ Autocommands ]]

local detect = require 'utils.detect-os'

-- [[ Highlight on yank ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  pattern = '*',
  desc = 'Briefly highlight yanked text',
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- [[ Template-y HTML ]]
--
-- Neovim's own filetype detection reclassifies any .html file containing `{{`
-- or `{%` as `htmldjango` (see runtime/lua/vim/filetype/detect.lua). That hits
-- Liquid/Shopify, Jinja, Vue, Angular, Handlebars and Alpine.js.
--
-- There is no `htmldjango` treesitter parser, so highlighting silently fell
-- back to legacy regex syntax. Point those filetypes at the html parser.
-- (The matching LSP `filetypes` widening lives in config/lsp.lua, and the
-- FileType handler that actually calls vim.treesitter.start - with a syntax
-- fallback - lives in plugins/treesitter.lua.)
vim.treesitter.language.register('html', { 'htmldjango', 'liquid' })

-- [[ Terminals ]]
--
-- Entering a terminal window should put you in terminal mode. Neovim otherwise
-- leaves you in normal mode and you have to press `i` every time.
--
-- Note this only fires when *entering* a terminal window. Pressing <Esc><Esc>
-- to reach normal mode and scroll back through output keeps working, because
-- staying in the same window fires no event.
local term_group = vim.api.nvim_create_augroup('TerminalMode', { clear = true })

vim.api.nvim_create_autocmd('TermOpen', {
  group = term_group,
  desc = 'Start in terminal mode and drop UI chrome',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd 'startinsert'
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  group = term_group,
  pattern = 'term://*',
  desc = 'Re-enter terminal mode when returning to a live terminal',
  callback = function(ev)
    -- Only if the job is still running; a finished terminal is just a buffer.
    if vim.bo[ev.buf].buftype == 'terminal' and vim.b[ev.buf].terminal_job_id then
      vim.cmd 'startinsert'
    end
  end,
})

-- [[ Git worktree session switching ]]
-- Follows `wt switch` / `cd` between worktrees from a :terminal. See the module
-- for why this uses OSC 7 rather than anything worktrunk-specific.
require('config.worktree').setup()

-- [[ WSL clipboard ]]
-- WSL has no native clipboard integration, so pipe yanks through clip.exe.
if detect.IS_WSL then
  local clip = '/mnt/c/Windows/System32/clip.exe'

  if vim.fn.executable(clip) == 1 then
    vim.api.nvim_create_autocmd('TextYankPost', {
      group = vim.api.nvim_create_augroup('WSLYank', { clear = true }),
      desc = 'Copy yanked text to the Windows clipboard',
      callback = function()
        if vim.v.event.operator == 'y' then
          vim.fn.system(clip, table.concat(vim.fn.getreg('"', 1, true), '\n'))
        end
      end,
    })
  end
end

-- vim: ts=2 sts=2 sw=2 et
