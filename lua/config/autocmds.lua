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
-- (The matching LSP `filetypes` widening lives in config/lsp.lua.)
vim.treesitter.language.register('html', { 'htmldjango', 'liquid' })

-- Safety net: if `vim.treesitter.start()` ever fails (an unparseable template,
-- a missing parser), restore regex syntax rather than leaving a plain-text
-- buffer with no highlighting at all.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('TreesitterHighlightFallback', { clear = true }),
  pattern = { 'html', 'htmldjango', 'liquid' },
  callback = function(ev)
    if not pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].syntax = 'ON'
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
